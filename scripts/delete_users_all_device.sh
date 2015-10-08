#!/bin/bash

./get_user_devices.tcl  | grep '"device_id":' | sed 's/^.*"device_id": "\(.*\)",$/\1/g' > file.txt$$

./delete_device_from_file.tcl file.txt$$

rm -f file.txt$$
