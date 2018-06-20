/*
 * @file        - updater.cpp
 * @description - Lwm2m Updater Client for Artik Thread based Edge devices
 * @author      - Vaibhav Singh (vaibhav1.s@samsung.com)
 * @date        - 14/10/2016
 *
*/
#include "json/json.hpp"
#include "hash/picosha2.h"
#include "ota_errors.h"
#include <fstream>
using json = nlohmann::json;


/* It receives the device information as a json file.
 * It starts the firmware update using the IP
 * It returns the errors as stated in ota_errors.h
*/

int main(int argc, char *argv[])
{
	const char* file = std::getenv("DEVICE_INFO");
	const char* pkg  = "package.json";

	if (!file) {
		std::cerr << "Missing DEVICE_INFO Env variable. Need Device Information File " << std::endl;
		return ERROR_UPDATER_MISSING_ARGUMENTS;
	}

	std::cout << "File is " << file << std::endl;

	try {
		std::ifstream devicestream(file);
		std::ifstream pkgstream(pkg);
		json device;		
		devicestream >> device;
		json package;
		pkgstream >> package;
		std::string firmware    = package["filename"];
		std::string app         = package["application"];
		std::string pkg_version = package["version"];
		std::string ver_uuid	= package["uuid"];
		std::cout << "filename is " << firmware << std::endl;
		std::cout << "application is " << firmware << std::endl;



		/* Verify Package Contents */
		{
			std::string hex_string;
			std::string pkg_sha  = package["sha256sum"];
			std::ifstream filestream(firmware);
			std::string file_str((std::istreambuf_iterator<char>(filestream)), 
				std::istreambuf_iterator<char>());
			picosha2::hash256_hex_string(file_str.begin(), file_str.end(), hex_string);
	
			std::cout << "SHA256 computed on firmware file is " << hex_string << std::endl;


			if (pkg_sha != hex_string) {
				std::cerr << "Mismatch SHA256  expected " << pkg_sha << std::endl;
				return ERROR_UPDATER_FIRMWARE_CORRUPTED;
			}
		}

		/* Get Node (Device) MAC address */
		std::string host = device["status"]["address"];
		std::string prefix = "coap://";
		std::string::size_type i = host.find(prefix);
		//std::string::firmware_ver = device["software"]["version"];
		if (i != std::string::npos)
			host.erase(i, prefix.length());

		host = host.substr(0, host.find_last_of(":"));
		host.erase(std::remove(host.begin(), host.end(), '['), host.end());
		host.erase(std::remove(host.begin(), host.end(), ']'), host.end());
		std::cout << "Device MAC Address is " << host << std::endl;
		/* Launch the TFTP App program */
		// Run the firmware updater
		std::string cmd = "./" + app + " -f " + firmware + " -a  "  + host + " -v " + pkg_version + " -u " + ver_uuid + " > firmwareupdate.log";
		std::cout << "launching command [" << cmd << "]" << std::endl;
		std::system(cmd.c_str());

		/* Verify result */
		try {
			
			std::ifstream ifs("firmwareupdate.log");
			std::stringstream buffer;
			buffer << ifs.rdbuf();
			std::string firmwareUpdateLogs = buffer.str();
			bool firmwareUpdateSuccess = (std::string::npos != (firmwareUpdateLogs.find("Sent Reboot POST request")));
			ifs.close();	
			if(firmwareUpdateSuccess == 1)
			{
				std::cout << "Successfully Rebooted" << std::endl;
				return UPDATER_SUCCESS; 	
			}
			else
			{
				std::system("cp firmwareupdate.log error.log");				
				std::cout << "Re-launching command [" << cmd << "]" << std::endl;
				std::system(cmd.c_str());
				std::ifstream ifs("firmwareupdate.log");
				std::stringstream buffer;
				buffer << ifs.rdbuf();
				std::string firmwareUpdateLogs = buffer.str();
				bool firmwareUpdateSuccess = (std::string::npos != (firmwareUpdateLogs.find("Sent Reboot POST request")));
				if(firmwareUpdateSuccess == 1)
				{
					std::cout << "Successfully Rebooted" << std::endl;
					return UPDATER_SUCCESS; 
				}
				else
				{
					std::cout << "Failed to Reboot" << std::endl;
					return ERROR_UPDATER_DEVICE_COMMUNICATION;
				}
				
			}


		} catch (std::exception& e) {
			std::cerr << " Result Exception "  << e.what();
		}

	} catch (std::exception &e) {
		std::cerr << "Exception while parsing json file  " << e.what() << std::endl;
		return ERROR_UPDATER_INVALID_JSON_FILE;
	}

	return UPDATER_SUCCESS;
}


