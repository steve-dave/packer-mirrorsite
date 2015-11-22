#!/bin/bash -e

# Add hostname to hosts file to suppress warning messages
sudo sed -i -e "s/^127\.0\.0\.1.*$/127.0.0.1 localhost $(hostname)/" /etc/hosts 2>/dev/null

# Disable IPv6 because it's not support by EC2
sudo sed -i -e 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="ipv6.disable=1"/' /etc/default/grub

# Update package database
sudo aptitude update

# Update all packages
sudo DEBIAN_FRONTEND=noninteractive aptitude -y dist-upgrade

# Install some basic packages
sudo DEBIAN_FRONTEND=noninteractive aptitude -y install apache2 sysstat ntp

# Set timezone
echo "Etc/UTC" | sudo tee /etc/timezone >/dev/null
sudo dpkg-reconfigure -f noninteractive tzdata

# Enable sysstat
sudo sed -i -e 's/ENABLED="false"/ENABLED="true"/' /etc/default/sysstat

# Install Apache configuration
sudo mv /tmp/000-default.conf /etc/apache2/sites-available/000-default.conf
sudo chown root:root /etc/apache2/sites-available/000-default.conf
sudo chmod 644 /etc/apache2/sites-available/000-default.conf

# Remove tmp directory
rm -rf /tmp/provisioner

# Mirror requested site
cd /var/www/html
sudo wget -nH -mp -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36' "$SITE" || ( echo "Exit code: $?"; exit 0 )
find . -name "*\?*" | while read file; do sudo mv "$file" "${file%%\?*}"; done
