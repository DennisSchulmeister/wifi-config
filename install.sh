#! /bin/sh

# wifi-config
# © 2023 Dennis Schulmeister-Zimolong <dennis@wpvs.de>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
set +e

INSTALL_PATH="/opt/wifi-config"
DOWNLOAD_URL="https://raw.githubusercontent.com/DennisSchulmeister/wifi-config/main/wifi-config"
FORUM_URL="https://github.com/DennisSchulmeister/wifi-config/discussions"
PROGRAM_NAME="wifi-config"

SUDO="sudo"

BLUE="\033[0;34m"
RED="\033[0;31m"
BOLD="\033[1m"
RESET="\033[0m"

confirm_or_exit() {
    read answer < /dev/tty

    if [ "$answer" != "Y" -a "$answer" != "y" ]; then
        echo "Aborting installation, as you wish. Have a nice day."
        exit 0
    else
        echo
    fi    
}

exit_on_error() {
    if [ $? -ne 0 ]; then
        printf "$RED"
        echo "An unexpected error occured during the installation."
        echo "Please get in contact with us, if you need help."
        echo
        printf "$BOLD"
        echo "  $FORUM_URL"
        echo
        printf "$RESET"

        exit 1
    fi
}

echo "Welcome to the wifi-config installation script."
echo
echo "wifi-config is a small program to set-up WiFi on bare-bones Linux systems."
echo "It helps you to setup wpa_supplicant for different types of Wifi."
echo
echo "Don't use it, if your WiFi is managed with NetworkManager."
echo "If you are running a stripped-down Linux version without Desktop, you are probably fine."
echo "In a full-blown Desktop environment, usually NetworkManager handles the WiFi for you."
echo
echo -n "Having said that, let's proceed. Shall we (Y/N)? "
confirm_or_exit

which wget 1> /dev/null 2> /dev/null

if [ $? -ne 0 ]; then
    printf "$RED"
    echo "This installation script needs wget to download files from the Internet."
    echo "Please install it using your local package manager."
    echo "On Debian, Ubuntu, Raspian or Raspberry Pi OS use the following command:"
    echo
    printf "$BOLD"
    echo "  sudo apt install wget"
    printf "$RESET$RED"
    echo
    echo "Other Linux systems have a similar tool for package installation."
    echo "Aftwards please restart the installation."
    printf "$RESET"
fi

echo "The programm will be installed to $INSTALL_PATH."
echo "You might need to enter your password to access that path."
echo

if [ -d "$INSTALL_PATH" ]; then
    echo "An exisiting installation was found in the directory above."
    echo -n "Do you want to remove the previous installation? (Y/N) "
    confirm_or_exit

    echo "Fine. Let's remove the old installation and start over."
    $SUDO rm -rf "$INSTALL_PATH"
    $SUDO rm -rf "/etc/profile.d/$PROGRAM_NAME.sh"

    echo
    echo -n "Done. Do you want to install a new version now? (Y/N) "
    confirm_or_exit
fi

echo "I will now download the program."
echo

$SUDO mkdir -p "$INSTALL_PATH"
exit_on_error

$SUDO wget --directory-prefix="$INSTALL_PATH" "$DOWNLOAD_URL"

if [ $? -ne 0 ]; then
    printf "$RED"
    echo "An error occured during the download."
    echo "Please check your Internet connection and try again."
    echo "To be sure, here you see your current IP addresses."
    echo
    printf "$BLUE"
    ip -brief addr show
    echo
    printf "$RED"
    echo "Are you really connected to the Internet?"
    printf "$RESET"
    exit 1
fi

$SUDO chmod +x "$INSTALL_PATH/$PROGRAM_NAME"
exit_on_error

tmpfile=$(mktemp)
echo "export PATH=\$PATH:$INSTALL_PATH" > "$tmpfile"
$SUDO mv "$tmpfile" "/etc/profile.d/$PROGRAM_NAME.sh"

echo "That's all. You might need to logout and login again, to be able to start the program."
echo "You can start the program with the following command then:"
echo
printf "$BLUE$BOLD"
echo "  $PROGRAM_NAME"
printf "$RESET"
echo
echo "While we are at it, please make sure to have the following programs installed:"
echo "wpa_supplicant, wpa_cli, iw, dialog"
echo
echo "Otherwise the program will not be able to start."
