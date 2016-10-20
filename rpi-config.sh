#!/usr/bin/env bash
# Raspberry Pi Configure

source rpi-config.conf

whoami=`whoami`

backup=${backup_folder:=~/backup}
mkdir -p $backup

######################
# Disclaimer
######################
echo ""
echo "$(date +%Y-%m-%d:%H:%M:%S) Script launched!"
echo "===================================================================="
echo " Automatic configuration for raspberry pi"
echo "===================================================================="
echo " Following configurations will be applied:   "
if [ ! -z ${custom_hostname} ]; then
    echo "     Hostname will be set to ${custom_hostname}"
fi
if [ ! -z ${boot_behaviour} ]; then
    echo "     Boot behaviour will be set to ${boot_behaviour}"
fi
if [ ! -z ${locales} ]; then
    echo "     ${locales} locales will be configured"
fi
if [ ! -z ${timezone} ]; then
    echo "     TimeZone will be set to ${timezone}"
fi
if [ ! -z ${network_ip} ] && [ ! -z ${network_netmask} ] && [ ! -z ${network_gateway} ] && [ ! -z ${network_dns_nameservers} ]; then
    echo "     Configure static IP address:"
    echo "         IP: ${network_ip}"
    echo "         Net mask: ${network_netmask}"
    echo "         Gateway: ${network_gateway}"
    echo "         DNS name servers: ${network_dns_nameservers}"
    echo ""
    echo "     Next time you want to connecto to your Raspberry use following IP: ${network_ip}"
    echo ""
fi
if [ ! -z ${wifi_country} ]; then
    echo "     WiFi country will be set to ${wifi_country}"
fi
if [ ! -z ${password_change} ] && [ $password_change = "yes" ]; then
    echo "     ${whoami} password will be changed"
fi
if [ ! -z ${expand_filesystem} ] && [ $expand_filesystem = "yes" ]; then
    echo "     File system will be expanded"
fi
if [ ! -z ${reboot} ] && [ $reboot = "yes" ]; then
    echo "     System will be rebooted and the end of the process"
fi
echo ""
echo " Original modified files will be copied in: ${backup}"
echo ""
echo " ====================================================================== "
echo " DISCLAIMER:   "
echo "     Jordi is not responsible for bricked devices, dead SD cards, or any other things "
echo "     script may break. You are using this at your own responsibility...."
echo " ====================================================================== "
sleep 1
read -n 1 -p "Do you accept above terms? (y/n)" terms_answer
echo ""

if [ "${terms_answer,,}" = "y" ]; then
        echo "$(date +%Y-%m-%d:%H:%M:%S) Starting configuration..."
else
        echo "$(date +%Y-%m-%d:%H:%M:%S) No changes were done, exiting"
        exit 1
fi

######################
# Configure hostname
######################
if [ ! -z ${custom_hostname} ]; then
    mkdir -p $backup/etc
    sudo cp /etc/hostname /etc/hosts $backup/etc/
    echo "$(date +%Y-%m-%d:%H:%M:%S) Set hostname to ${custom_hostname}"
    sudo raspi-config nonint do_hostname ${custom_hostname}
fi
######################
# Configure boot behaviour
######################
if [ ! -z ${boot_behaviour} ]; then
    echo "$(date +%Y-%m-%d:%H:%M:%S) Change boot behaviour to ${boot_behaviour}"
    sudo raspi-config nonint do_boot_behaviour ${boot_behaviour}
fi

######################
# Configure Locales
######################
if [ ! -z ${locales} ]; then
    echo "$(date +%Y-%m-%d:%H:%M:%S) Configure locales $locales"
    mkdir -p $backup/etc
    sudo cp /etc/locale.gen $backup/etc
    # Deactivate en_GB.UTF-8. This is the default locale.
    sudo sed -i -- "s/^en_GB\.UTF-8/# en_GB\.UTF-8/g" /etc/locale.gen

    # Activate locales in config file
    export IFS=","
    for locale in $locales; do
        echo "Adding $locale"
        sudo sed -i -- "s/^# $locale/$locale/g" /etc/locale.gen
    done

    sudo dpkg-reconfigure -f noninteractive locales 2>&1
fi

######################
# Set TimeZone
######################
if [ ! -z ${timezone} ]; then
    echo "$(date +%Y-%m-%d:%H:%M:%S) Set TimeZone to ${timezone}"
    sudo cp /etc/timezone $backup/etc
    sudo bash -c "echo $timezone > /etc/timezone"
    sudo dpkg-reconfigure -f noninteractive tzdata 2>&1
fi

######################
# Configure static IP
######################
if [ ! -z ${network_ip} ] && [ ! -z ${network_netmask} ] && [ ! -z ${network_gateway} ] && [ ! -z ${network_dns_nameservers} ]; then
    mkdir -p $backup/etc/network
    sudo cp /etc/network/interfaces $backup/etc/network
    echo "$(date +%Y-%m-%d:%H:%M:%S) Configure static IP"
    echo "$(date +%Y-%m-%d:%H:%M:%S)     IP: ${network_ip}"
    echo "$(date +%Y-%m-%d:%H:%M:%S)     Net mask: ${network_netmask}"
    echo "$(date +%Y-%m-%d:%H:%M:%S)     Gateway: ${network_gateway}"
    echo "$(date +%Y-%m-%d:%H:%M:%S)     DNS name servers: ${network_dns_nameservers}"
    sudo sed -i -- "s/^auto lo/auto eth0/g" /etc/network/interfaces
    sudo sed -i -- "s/^iface eth0 inet manual/iface eth0 inet static\n   address $network_ip\n   netmask $network_netmask\n   gateway $network_gateway\n   dns-nameservers $network_dns_nameservers/g" /etc/network/interfaces
fi

######################
# Disable IPv6
######################
if [ ! -z ${network_disable_ipv6} ] && [ $network_disable_ipv6 = "yes" ]; then
    echo "$(date +%Y-%m-%d:%H:%M:%S) Disable IPv6"
    sudo cp /etc/sysctl.conf $backup/etc

    disable_ipv6=`cat /etc/sysctl.conf | grep "net.ipv6.conf.all.disable_ipv6" | wc -l`
    if [ ${disable_ipv6} -lt 1 ]; then
        sudo echo "net.ipv6.conf.all.disable_ipv6 = 1" | sudo tee --append /etc/sysctl.conf > /dev/null
    else
        sudo sed -i -- "s/^net.ipv6.conf.all.disable_ipv6.*/net.ipv6.conf.all.disable_ipv6 = 1/g" /etc/sysctl.conf
    fi
    sudo sysctl -p
    sudo ifconfig eth0 down && sudo ifconfig eth0 up
    sleep 10
fi

######################
# Configure WiFi
######################
if [ ! -z ${wifi_country} ]; then
    echo "$(date +%Y-%m-%d:%H:%M:%S) Set WiFi country to ${wifi_country}"
    mkdir -p $backup/etc/wpa_supplicant
    sudo cp /etc/wpa_supplicant/wpa_supplicant.conf $backup/etc/wpa_supplicant
    sudo sed -i "s/^country=.*/country=$wifi_country/g" /etc/wpa_supplicant/wpa_supplicant.conf
fi

######################
# Change user password
######################
if [ ! -z ${password_change} ] && [ $password_change = "yes" ]; then
    echo "$(date +%Y-%m-%d:%H:%M:%S) Change ${whoami} user password"
    passwd ${whoami}
fi

######################
# Expand filesystem
######################
if [ ! -z ${expand_filesystem} ] && [ $expand_filesystem = "yes" ]; then
    echo "$(date +%Y-%m-%d:%H:%M:%S) Expand filesystem"
    sudo raspi-config --expand-rootfs
fi

######################
# Reboot
######################
if [ ! -z ${reboot} ] && [ $reboot = "yes" ]; then
    echo "$(date +%Y-%m-%d:%H:%M:%S) Rebooting in 5 seconds..."
    sleep 5
    # Reboot
    sudo reboot
else 
    echo "$(date +%Y-%m-%d:%H:%M:%S) Please, remember that some of the changes need a reboot to take effect..."
fi
