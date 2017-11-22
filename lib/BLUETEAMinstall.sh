#!/bin/sh

clear
echo " ================================================================= "
echo "|  Blue Team Training Toolkit - Install Script                    |"
echo "|  by Juan J. Guelfo, Encripto AS (post@encripto.no)              |"
echo " ================================================================= "


if [ "$(id -u)" != "0" ]; then
   echo "\n\n\033[1;31m[-]\033[1;m .\n"
   exit 1
fi



echo "\n\n\033[1;34m[*]\033[1;m ...\n"
sleep 1


echo "\n\n\033[1;34m[*]\033[1;m Generating PEM..."
sleep 1
cat server.crt server.key > server.pem
echo "\033[1;32m[+]\033[1;m Certificate successfully generated."

cd ..
echo "\n\033[1;34m[*]\033[1;m Assigning ownership and permissions to files..."
chown root:root -R $(pwd)
chmod 755 -R $(pwd)
chmod 755 -R $(pwd)/*

echo "\n\033[1;32m[+]\033[1;m Installation completed!\n"
