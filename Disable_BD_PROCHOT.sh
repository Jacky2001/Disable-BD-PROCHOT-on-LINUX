printf "Disable BD PROCHOT on LINUX\n\n"
printf "A script containing the commands to disable BD PROCHOT will be created and placed in a boot directory with administrator privileges\n\n"

while true; do
	read -rp "Do you wish to continue? [y/N]: " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) printf "Error: just write 'y' or 'n'\n\n";;
		esac
    done

if [ "$(id -u)" != 0 ]; then
	printf "This script requires administrator privileges\n"
	sudo "$0" "$@"
	exit
fi

printf "Installing needed packages..\n\n"
printf "Which distribution do you want to install for?\n\n"
printf "1. Arch Linux\n"
printf "2. Ubuntu and derivatives\n"
printf "3. Fedora and derivatives\n"
printf "4. CentOS\n\n"

while true; do
	read -rp "Choose an option [1/2/3/4]: " option
		case $option in
			1 ) sudo pacman -S msr-tools; break;;
			2 ) sudo apt-get install msr-tools; break;;
			3 ) sudo dnf install msr-tools; break;;
			4 ) sudo yum install msr-tools; break;;
			* ) printf "Error: just write a number between 1 and 4\n\n";;
		esac
    done

sudo nano /usr/local/bin/disable_bd_prochot.sh << EOF
#!/bin/bash
modprobe msr
rdmsr 0x1FC
wrmsr 0x1FC value
EOF

sudo chmod +x /usr/local/bin/disable_bd_prochot.sh

sudo nano /etc/systemd/system/disable_bd_prochot.service << EOF
[Unit]
Description=Disable BD PROCHOT

[Service]
Type=oneshot
ExecStart=/usr/local/bin/disable_bd_prochot.sh

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable disable_bd_prochot.service

while true; do
	read -rp "Do you wish to reboot system? [y/N]: " yn
		case $yn in
			[Yy]* ) sudo reboot; break;;
			[Nn]* ) exit;;
			* ) printf "Error: just write 'y' or 'n'\n\n";;
		esac
    done
