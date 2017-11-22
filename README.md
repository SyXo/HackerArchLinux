# **README**

## Arch Linux customized
> This repository contains auto-installation scripts and personalized configuration files that will install and configure a laptop powered by dual-homed video cards Intel+Nvidia with the full 
> set of programming, PenTesting and Hacking tools and utilities to accomplish any task.

> This installation assumes a laptop with dual-homed graphics cards (Intel + NVIDIA).

#### **Installation**:

> This installation requires some minimal setup in order to work, and knowledge of linux and programming in 2 languages __Perl & Python__ if something goes wrong.
> ##### Steps: #####
> 1. Download Arch Linux latest ISO : https://www.archlinux.org/download/ 
> 2. Create a bootable USB flash drive with the ISO ; boot your computer created USB drive
> 3. Follow primary disk partitioning below (`cfdisk /dev/sda`) >> `mkfs.ext* /dev/sd*`
>  * Once you get command prompt, type:
> 2. `git clone https://github.com/mikigure/HackerArchLinux.git` May or may not work - git to another location and copy files to iso /root.
> 3. `sh start`
> 4. Once the initialization and staging of the new system is complete, the final stage is the installation of all usermode programs, starting with the UI.
> * see [Programs List](PROGRAMS.md) for full table listing
> 5. If for whatever reason the install or extras script doesn't automatically start after reboot, type `source ~/.bashrc` and the process will continue.

#### **Requirements**:
> Only have to have the partitions exist as specified (mounting is done in the script).
> Feel free to adjust the script to your liking of mounts; however, I found this to be the minimum for easier separation for security measures (linux mount points).

> If you want hibernation, swap is required to equal the amount of RAM you have.
> SSD drives will be automatically detected and the 'discard' flag will be added to those drives inside fstab upon creation.

* Primary disk and partitioning:

|    Partition       |     Disk purpose
|--------------------|-----------------------
|/dev/sda1 (ext2)    |  **/boot**  ( recomm: 800MB )
|/dev/sda2 (swap)    |  **swap**   ( recomm: 8G , min: 4G )
|/dev/sda3           |  _extended partition_
| ->/dev/sda5 (ext4) |  **/**      _( recomm: 40GB , min: 30+ GB )_
| ->/dev/sda6 (ext4) |  **/tmp**   _( recomm: 8G , min: 4GB )_
| ->/dev/sda7 (ext4) |  **/home**  _( the rest of the drive )_


#### FYI:
> Currently, the scripts have some rudimentary error checking and immediate failure, so if for whatever reason the script 'dies' (if certain items fail to complete successful, 
> the process cannot and should not continue and will require you to restart the script and rerun **ONLY** the parts that have failed).
> I have done my best (and currently out of energy to continue further ; I will polish this script at some point) to make this script painlessly simple and user-input free, 
> however, please see the below TODO to understand.
> In order to have this setup fully operational you need to pull out your monitor names:  ```ll /sys/class/drm | awk -F " " '{print $9}' | grep "card" ``` 
> and change out respective lines in ~/.config/i3/config & /etc/lightdm/lightdm.conf

##### TODO/BUGS:
- [ ] **Proper error checking respective to operation**
- [ ] **Logging output and consolidation of install command output**
- [ ] **Create logging sqlitedb - tracking each operation as successful or failed**
- [ ] Ask if there are previously created home dir and mount without format
- [ ] netctl for wifi carry-over to new system
- [ ] Add metasploit , BT3 (BlueTeam Training Toolkit) installs
- [ ] Finish auto-ricing ; chown , chmod to home dir
- [ ] Add one-time install of zim + vundle inside UI
- [ ] Build xrandr monitor line from properties ; add to lightdm & i3 config files
- [ ] Build sshd profile (moduli)
- [ ] Clean files and folders created along install process
- [ ] Encrypted "home" directory LLVM; password protected GRUB edits
- [ ] System cleanup script (.cache/{makepkg,pacaur})
- [x] Fix: bugs in BuildFstab.py - verify drives ; mkswap
- [x] ReWrite the Blackarch install script into Perl (error-proofing)
- [x] Finish automation (staing -> install -> extras)
