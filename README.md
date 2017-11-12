# **README**

## Arch Linux customized
> This repository contains auto-installation scripts and personalized configuration files that will install and configure a laptop powered by dual-homed video cards Intel+Nvidia with the full set of programming, PenTesting and Hacking tools and utilities to accomplish any task.

#### **Installation**:
> This installation requires some minimal setup in order to work, and knowledge of linux and programming in 2 languages __Perl & Python__ if something goes wrong.

#### **Requirements**:
> Only have to have the partitions exist as specified (mounting is done in the script).
> Feel free to adjust the script to your liking of mounts; however, I found this to be the minimum for easier separation for security measures (linux mount points).

> If you want hibernation, swap is required to equal the amount of RAM you have.
> SSD drives will be automatically detected and the 'discard' flag will be added to those drives inside fstab upon creation.

1. Primary disk and partitioning:

|    Partition       |     Disk purpose
|--------------------|-----------------------
|/dev/sda1 (ext2)    |  **/boot**  ( recomm: 800MB )
|/dev/sda2 (swap)    |  **swap**   ( recomm: 8G , min: 4G )
|/dev/sda3           |  _extended partition_
| ->/dev/sda5 (ext4) |    **-> /**      _( recomm: 40GB , min: 30+ GB )_
|  ->/dev/sda6 (ext4)|    **-> /tmp**   _( recomm: 8G , min: 4GB )_
|  ->/dev/sda7 (ext4)|    **-> /home**  _( the rest of the drive )_

2. Make sure you are connected to the internet!
	* The script will check as part of the requirements to start the install process; however, the script will exit out in cases of failure.

3. Run 'perl Arch.pl' script and the process will commence.

4. The first 2 parts to the install, __Init & Staging__, usually complete without any issues. This will bring up a working Arch Linux install from boot to the command prompt.
	* The staging process requires user input for the setting up of the new host.
	* **Before typing "EXIT", you must adjust the /etc/fstab file (1) delete the extra mount points, if any and (2) delete the secondary label to swap**

5. The install process is divided into 2 parts:
	1. The install of the user environment along with the full set of end-user needs (see [Programs List](PROGRAMS.md) for full table listing.
	2. The extra programs that are not part of the standard repositories of Arch Linux and are the meat of this install. __Sometimes there are problems with this part of the install as there are unstable scripts (not mine!)__

#### FYI:
> Currently, the scripts have some rudimentary error checking and immediate failure, so if for whatever reason the script 'dies' (if certain items fail to complete successful, the process cannot and should not continue and will require you to restart the script and rerun **ONLY** the parts that have failed).
> I have done my best (and currently out of energy to continue further ; I will polish this script at some point) to make this script painlessly simple and user-input free, however, please see the below TODO to understand.
> In order to have this setup fully operational you need to pull out your monitor names:  ```ll /sys/class/drm | awk -F " " '{print $9}' | grep "card" ``` and change out respective lines in ~/.config/i3/config & /etc/lightdm/lightdm.conf

##### TODO/BUGS:
> [ ] Finish automation (install -> extras -> ricing)
> [ ] More advanced command output error checking
> [ ] Create db for what has successfully run and failed and rerun the necessary parts again automatically without user input.
> [ ] Logging output and consolidation of install command output
> [ ] ReWrite the Blackarch install script into Perl/Python for error proofing
> [ ] Add metasploit , BT3 (BlueTeam Training Toolkit)
> [ ] Add auto find monitors and add to lightdm & i3-config
> [ ] Clean files and folders created along install process
> [ ] Finish auto-ricing ; chown , chmod to home dir
> [ ] Add one-time install of zim + vundle inside UI
