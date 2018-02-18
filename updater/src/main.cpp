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
	const char* pkg  = "package.json";
	
	if(argv[1] == NULL)
	{
		printf("\nISSUE: Provide MAC of Device");
		return ERROR_UPDATER_MISSING_ARGUMENTS;
	}

	try {
		std::ifstream pkgstream(pkg);
		json package;
		pkgstream >> package;
		std::string firmware    = package["filename"];
		std::string app         = package["application"];
		std::string pkg_version = package["version"];
		std::string pkg_action  = package["action"];		
		int version_status = pkg_version.compare(argv[2]);
		std::cout <<"version status"<<version_status<<std::endl;	
		if (version_status == 0 && pkg_action == "s")
		{
			std::cout << "same version to be updated"<<std::endl;
		}else if (version_status < -0 && pkg_action == "d")
		{
			std::cout << "downgraded version to be applied"<<std::endl;			
		}else if (version_status > 0 && pkg_action == "u")
		{
			std::cout << "upraded version to be applied"<<std::endl;			
		}else
		{
			std::cout << "Package Version Error"<<std::endl;
			return ERROR_UPDATER_SAME_FIRMWARE;	
		}		
		
		std::cout << "Firmware is " << firmware << std::endl;


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

		/* Get Node (Device) address */
		printf("\n \nMAC is %s\n", argv[1]);
		std::string device_id = argv[1];
		/* Launch the flash programmer */
		// Run the firmware updater
		std::string cmd = "./" + app + " --file " + firmware + " --target  "  + device_id + " > /root/firmwareupdate.log";
		std::cout << "\nlaunching command [" << cmd << "]" << std::endl;
		std::system(cmd.c_str());

		/* Verify result */
		try {
			std::ifstream ifs("firmwareupdate.log");
			std::stringstream buffer;
			buffer << ifs.rdbuf();
			std::string firmwareUpdateLogs = buffer.str();
			bool firmwareUpdateSuccess = (std::string::npos != (firmwareUpdateLogs.find("Replacing image")));

			return (firmwareUpdateSuccess ? UPDATER_SUCCESS : ERROR_UPDATER_DEVICE_COMMUNICATION);

		} catch (std::exception& e) {
			std::cerr << " Result Exception "  << e.what();
		}

	} catch (std::exception &e) {
		std::cerr << "Exception while parsing json file  " << e.what() << std::endl;
		return ERROR_UPDATER_INVALID_JSON_FILE;
	}

	return UPDATER_SUCCESS;
}


