# rpi-config
Script to automate configurations usually done in a fresh Rasbian Stretch installation.

Note that all modified files will be copied to a backup folder `(default: /home/pi/backup)`

## Currently supported configurations:
- Expand file system
- Configure boot behaviour
- Configure locales
- Configure time zone
- Change the password from current user (usually pi). You will be promted for new password.
- Set WiFi country
- Configure static IP address
- Disable IPv6

## Requirements
- Raspberry Pi 3 Model B
- Fresh Rasbian Stretch intallation running

### Follow next steps to install a fresh Rasbian onto Raspberry Pi
1. Download Rasbian Stretch from [here] (https://www.raspberrypi.org/downloads/raspbian/)
2. Extract zip file containing disk image
3. Download and install [Win32DiskImager] (https://sourceforge.net/projects/win32diskimager/)
4. Copy image file to SD card using Win32DiskImager
5. **IMPORTANT!!! Since Nov 2016 SSH is disabled by default; it can be enabled by creating a file with name "ssh" in boot partition**
6. Plug SD card into Pi, power up 

## Use the script
You need to adapt the `rpi-config.conf` file to your needs and run the script.

### Follow next steps to execute the script
1. Use an app like [FING] (https://play.google.com/store/apps/details?id=com.overlook.android.fing&hl=en) to find your Pi's IP address 
2. Using [Putty] (http://www.putty.org) connect to Pi via SSH, use user: `pi` password: `raspberry`
3. Execute `wget -Nnv https://raw.githubusercontent.com/hokus15/rpi-config/master/rpi-config.conf`
4. Execute `nano rpi-config.conf`
5. Make modifications to adapt configuration to your needs
6. Hit `control-x`, then press `Y`
7. Execute `wget -Nnv https://raw.githubusercontent.com/hokus15/rpi-config/master/rpi-config.sh && bash rpi-config.sh | tee $(date +%Y%m%d%H%M%S)-rpi-config.log`

If configuration in `rpi-config.conf` suit your needs you can skip steps from 3 to 7 and execute directly:
```
wget -Nnv https://raw.githubusercontent.com/hokus15/rpi-config/master/rpi-config.conf && wget -Nnv https://raw.githubusercontent.com/hokus15/rpi-config/master/rpi-config.sh && bash rpi-config.sh | tee $(date +%Y%m%d%H%M%S)-rpi-config.log
```

## Disclaimer
I'm not responsible for bricked devices, dead SD cards, or any other things script may break. You are using this at your own responsibility...

Feel free to modify the script and config file at your convenience.
