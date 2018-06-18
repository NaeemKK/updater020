#ifndef __OTA_ERRORS__
#define __OTA_ERRORS__

/* It receives the device information as a json file.
 * It starts the firmware update using the IP
 * It returns the following=
    -1 : Missing arguments
	-2 : Invalid device json file
	-3 : Firmware File Corrupted
	-4 : Device Communication Error
*/

#define UPDATER_SUCCESS 0
#define ERROR_UPDATER_MISSING_ARGUMENTS -1
#define ERROR_UPDATER_INVALID_JSON_FILE -2
#define ERROR_UPDATER_FIRMWARE_CORRUPTED -3
#define ERROR_UPDATER_DEVICE_COMMUNICATION -4
#define ERROR_UPDATER_SAME_FIRMWARE -5
#define ERROR_UPDATER_UNKNOWN -6

#endif
