#<div style="background-color:#002060; padding:4px 8px 4px 20px">UJE_YUN firmware 17.01.4.FPU_EMULATION</div>



##<div style="background-color:#B0BFDC; padding:4px 8px 4px 20px">Description</div>

- Firmware specially adapted for the Arduino Yún.
- U-boot 1.1.5 Bootloader, with 'saveenv' support.
- LEDE 17.01.4, with FPU_EMULATION (needed for NodeJS).






##<div style="background-color:#B0BFDC; padding:4px 8px 4px 20px">Creating a cross-compiled custom firmware</div>

####The host computer
A cross-compile is done on a Linux computer (not the Yún).
We ran ***Linux Debian*** as a virtual machine (on a fast Apple computer).

####Create and enter your ***LEDE*** folder
```

        mkdir /usr/src/LEDE
        cd /usr/src/LEDE

```
This will become the location where you want the LEDE source-code placed.


####Copy the ***SETUP*** folder to your ***LEDE*** folder
```

        cp -R /from/here/SETUP .

```
>  Example: If your *path_to_*LEDE is ***/usr/src/LEDE***
>           you will end up with this: ***/usr/src/LEDE/SETUP***


####Download the LEDE 17.01.4 source-code
```

        git clone --depth=1 --branch v17.01.4 --single-branch https://git.lede-project.org/source.git

```
>  Now you should have a ***source*** folder created.


####Enter the ***LEDE source*** folder
```

        cd source

```


####Feeds
```

        ./scripts/feeds update -a
        ./scripts/feeds install -a

```
> Now there is a folder: ***source/package/feeds***

At this time the LEDE Node feeds have been installed,
we need to remove them, before adding nxhack Node:

```

        rm ./package/feeds/lede_packages/node
        rm ./package/feeds/lede_packages/node-arduino-firmata
        rm ./package/feeds/lede_packages/node-cylon
        rm ./package/feeds/lede_packages/node-hid
        rm ./package/feeds/lede_packages/node-serialport

        ./scripts/feeds install -a -p node

```

####Copy the Yún specific ***SETUP files*** folder to your ***LEDE source*** folder
```

        cp -R ../SETUP/files .

```


####Overwrite existing LEDE configuration files with the UJE_YUN config files
```

        cp ../SETUP/source____.config .config
        cp ../SETUP/source____feeds.conf.default feeds.conf.default
        cp ../SETUP/source_target_linux_ar7_image____Makefile target/linux/ar7/image/Makefile
        cp ../SETUP/source_target_linux_ar71xx____config-4.4 target/linux/ar71xx/config-4.4
        cp ../SETUP/source_target_linux_ar71xx_image____generic.mk target/linux/ar71xx/image/generic.mk
        cp ../SETUP/source_target_linux_ar71xx_image____legacy.mk target/linux/ar71xx/image/legacy.mk
        cp ../SETUP/source_target_linux_ar71xx_image____legacy-devices.mk target/linux/ar71xx/image/legacy-devices.mk

```


####The UJE_YUN configuration settings
```

        make kernel_menuconfig
        make menuconfig

```
>  When you exit kernel_menuconfig and menuconfig,
>  if asked to write the config, confirm with YES.


####Now it is time to perform the cross-compile
```

        make

```


####Check your freshly created, cross-compiled firmware
On a succesful compile you will find the firmware files at this location:

***path_to_your_LEDE/source/bin/targets/ar71xx/generic***

```

        ls /usr/src/LEDE/source/bin/targets/ar71xx/generic

```






##<div style="background-color:#B0BFDC; padding:4px 8px 4px 20px">Flashing the firmware</div>

####UJE_YUN changes to original LEDE firmware
We dropped the use of the NVRAM partition since it it not used at all on a Yún. The resulting extra 64k memory raise the maximum size of the UJE_YUN firmware to 16000k.
We also decided to break with the Yún tradition of firmware memory arrangement. The UJE_YUN kernel always boots from memory address 0x9f050000, and the rootfs is located behind the kernel. The other flash-partitions are left at their default locations.
The UJE_YUN flash memory arrangement looks like this:
- u-boot 1.1.5 bootloader, starts at address 0x9f000000, 256k is reserved
- u-boot-env, starts at address 0x9f040000, size is 64k
- UJE_YUN firmware (kernel+rootfs), starts at address 0x9f050000, 16000k is reserved
- art (Atheros Radio Test), starts at address 0x9fFF0000, size is 64k
The UJE_YUN firmware maximum address space is 16000k. The firmware consists of a kernel and a rootfs. The combined size of kernel+rootfs can never exceed 16000k.
You can however use any size kernel. Say for example, you have compiled a 2048k kernel. This means that your rootfs can have a maximum size of 16000k - 2048k = 13952k. The individual sizes of kernel & rootfs do not matter: It's the combined size of the firmware that's important. In the end, all must fit in the 16M flash of the Atheros AR9330.

####Preparing for a firmware flash
- Connect the Yún via the ethernet with a cable
- Run a ***tftp server*** on a host computer, providing the firmware files to flash
- In u-boot set ***serverip*** and ***ipaddr***. Suppose your host uses ip-address 192.168.178.100, and your Yún uses ip-address 192.168.178.107, you need to do:

```
  ubootprompt>setenv serverip 192.168.178.100
  ubootprompt>setenv ipaddr 192.168.178.107
```

####u-boot flash partition
The bootloader, named u-boot, is very important. It functions like the BIOS of a PC. Without a working bootloader, the Yún will not power up, and will appear bricked.
Traditionally 256k flash memory is allocated for the bootloader. While the filesize of the (newer) u-boot 1.1.5 is 179k, always allocate 256k of flash memory when flashing a new bootloader.
The original Yún bootloader (u-boot 1.1.4) does not permit someone to adjust the environment settings. Therefore it is impossible to flash firmware that is not compatible with the original u-boot environment. In other words: If your kernel ***or*** rootfs size exceeds the original Yún allocated space, you can not flash your firmware because it would not fit.
The original Yún sizes are set to: 14656k(rootfs),1280k(kernel).
The newer bootloader u-boot 1.1.5 supports the ***saveenv*** command (and lots more). We need to upgrade an original Yún with this newer bootloader. Here's how to do it:

```
  ubootprompt>tftp 0x80060000 u-boot-linino-yun.bin;
  ubootprompt>erase 0x9f000000 +40000;
  ubootprompt>cp.b $fileaddr 0x9f000000 $filesize;
  ubootprompt>erase 0x9f040000 +10000;
```
> After flashing a new u-boot, also allocate the u-boot-env.
> You need to reboot your Yún.

Upgrading the bootloader is not part of a firmware flash.
Once you upgraded the Yún with a new bootloader, you do ***not*** have to do it again at every next firmware flash.

***BE VERY CAREFUL WHEN ERASING AND/OR FLASHING TO u-boot FLASH MEMORY SPACE***
If it goes wrong, (for example if you flash the bootloader space with some wrong file), the Yún may appear bricked, but many times you can bring it back to a working state.
You can revive a "bricked" Yún (even if it doesn't even show up in the Arduino IDE with a COM-port anymore). You would use another ***Arduino as ISP*** to program the Yún with a new bootloader, and later flash a working firmware into the Yún.

####Prepare the u-boot environment settings before flashing UJE_YUN firmware
To be able to flash a new firmware that is not compatible with the original memory layout, you need to adjust the u-boot environment settings ***and save the new settings so they remain after a boot***.
When the Yún boots, you can see the MTD (Memory Technology Device) information displayed, showing the current flash memory layout being used.
To change the u-boot settings for our UJE_YUN example, we would execute the following commands on the u-boot command-line:

```
  ubootprompt>setenv mtdparts "spi0.0:256k(u-boot)ro,64k(u-boot-env),1152k(kernel),14848k(rootfs),64k(art)ro"
  ubootprompt>setenv bootcmd "run addboard; run addtty;run addparts; run addrootfs; bootm 0x9f050000"
  ubootprompt>saveenv
```

####Kernel memory alignment & padding
Flash memory can only be programmed in blocks of 64k, and there are 256 of those blocks available in the 16M flash space of the Yún.
In hexadecimal notation 64k = 0x10000. This means that start-addresses must always be multiples of 64k.
The UJE_YUN kernel start-address is fixed at 0x9f050000; No problem there. 0x50000 is a 64k multiple.
However, when allocating the flash-partition for the kernel, the actual kernel size is important. While you can partly fill a flash memory-block, you can only allocate per full block. If you have compiled a kernel that has a size that is not a 64k multiple, (for example 1150k), you need to pad the size to the next 64k boundry (which wil be 1152k for the example kernel).
In practice, when you would flash the 1150k example kernel, you would have to allocate 0x120000 bytes (=1152k), and write the 1150k kernel file.
In u-boot you would execute the following commands to flash that kernel correctly:

```

  ubootprompt>tftp 0x80060000 your_1150k_kernel_file.bin
  ubootprompt>erase 0x9f050000 +120000
  ubootprompt>cp.b $fileaddr 0x9f050000 $filesize;

```

####rootfs memory alignment & padding

Once you know your padded-to-64k kernel size, you can calculate the remaining memory space for the rootfs.
The UJE_YUN total firmware size is always fixed to be 16000k.
In our example with the 1150k kernel file, the padded size will be 1152k (0x120000).
That leaves space for a 16000k - 1152k = 14848k rootfs.
If we allocate flash memory for the (example) rootfs, we must always allocate that maximum size we just calculated: 14848k (0xE80000).
The resulting allocation size of the rootfs will also always be a multiple of 64k.
If your compiled rootfs is <= 14848k then you are able to flash your firmware files.
Suppose in our example we have produced a rootfs file of 14720k. That file is small enough to fit in the remaining flash memory (14848k).
Now you only need to calculate the flash start-address of the rootfs. For that, you need to know the (allocated) kernel size, in our case: 1152k (0x120000).
The rootfs is located behind: u-boot, u-boot-env, kernel, rootfs is next. We know all the sizes of those flash-partitions: 256k, 64k, 1152k (and the rootfs allocated partition size will be 14848k).
We can calculate the start-address of the rootfs: 256k + 64k + 1152k = 1472k  (0x040000 + 0x010000 + 0x120000 = 0x170000).
Here's what you need to do to flash that example rootfs:

```

  ubootprompt>tftp 0x80060000 your_14720k_rootfs_file.bin
  ubootprompt>erase 0x9f170000 +E80000
  ubootprompt>cp.b $fileaddr 0x9f170000 $filesize;

```

####art flash partition

The art flash partition (Atheros Radio Test) is always located at address 0x9fFF0000, and it occupies the last 64k of the flash memory.
Remember to flash the art partition again, if you choose to place it at another address in flash. (For example: When you flash manually, and you have smaller firmware files and allocate less flash-memory for them, and want to put the art-partition immediately behind your firmware in memory).
The art file is also compiled and can be found in your bin folder along the other firmware files. The filename is: ***linino-caldata.bin***
If you want to flash the art-partition, you can do it like this:

```

  ubootprompt>tftp 0x80060000 linino-caldata.bin
  ubootprompt>erase 0x9fff0000 +10000
  ubootprompt>cp.b $fileaddr 0x9fff0000 $filesize;

```


####Example UJE_YUN flash layout:
```

                    ____________________ ____________________ ____________________ ____________________ ____________________ 
                   |                    |                    |                    |                    |                    |
                   | u-boot             | u-boot-env         | kernel             | rootfs             |   art              |
             start |        0x9f000000  |        0x9f040000  |        0x9f050000  |        0x9f170000  |        0x9fFF0000  |
            length | 256k        40000  | 64k         10000  | 1150k      11F800  | 14720k     E60000  | 64k         10000  |
        pad-to 64k |                    |                    | 1152k      120000  |            E60000  |                    |
               end |        0x9f040000  |        0x9f050000  |        0x9f170000  |        0x9fFD0000  |        0xA0000000  |
                   |                    |                    |                    | pad-to-max +20000  |                    |
                   |                    |                    |                    | max    0x9fFF0000  |                    |
                   |                    |                    |                    |                    |                    |
                   |                    |                    | padded kernel:     | FF0000 - 170000 =  |                    |
          mtdparts | 256k(u-boot)ro     | 64k(u-boot-env)    | 1152k(kernel)      | 14848k(rootfs)     | 64k(art)ro         |
                   |                    |                    |                    |                    |                    |
          FW flash |                    |                    | erase  .  +120000  | erase  .  +E80000  |                    |
                   |                    |                    | cp.b . . filesize  | cp.b . . filesize  |                    |
                   |____________________|____________________|____________________|____________________|____________________|

```
>  Note: This is just an example. The numbers may vary with your own compiled firmware sizes.


##<div style="background-color:#B0BFDC; padding:4px 8px 4px 20px">Setup a network for the UJE_YUN</div>

####Connect to the Yún wireless network

Just leave the ethernet cable connected.
- Find the UJE_YUN wireless hotspot, named: ***homeYun***, and connect to it
- Once connected, in the webbrowser go to the UJE_YUN IP at: ***192.168.1.1***
- Luci will show you the login page. Login as ***root*** with the default password: ***arduino***
- Select *System, Administration* and ***adjust the password***
- Select *Network, Wireless* and *Scan* for your local LAN WiFi access point
- *Connect* to your LAN WiFi.
> Once connected to your LAN WiFi, you can disable the homeYun's wireless AP if you want. Just do not disable all connections!
> Note: You can not disable the homeYun AP _before_ joining another network. If you disconnect your ethernet cable, there is no way of connecting your Yún again.


##<div style="background-color:#B0BFDC; padding:4px 8px 4px 20px">Using an SDcard to expand the Yún Linux memory</div>

####Extroot overlay

```

        # destroy partition information
        dd if=/dev/zero of=/dev/sda bs=4096 count=10

        # create 3 partitions for a 16G SDcard:   sda1 ext4 overlay (10G),   sda2 vfat (4G),   sda3 swap (rest)
        (echo o; echo n; echo p; echo 1; echo; echo +10G; echo n; echo p; echo 2; echo; echo +4G; echo n; echo p; echo 3; echo; echo; echo t; echo 1; echo c; echo t; echo 3; echo 82; echo w) | fdisk /dev/sda

        umount /dev/sda?
        rm -rf /mnt/sda?

        #delay(5000)

        umount /dev/sda?
        rm -rf /mnt/sda?

        # format partition 1 as ext4
        mkfs.ext4 /dev/sda1

        #delay(100);

        # format partition 2 as vfat
        mkfs.fat /dev/sda2        		

        # make partition 3 a swap
        mkswap /dev/sda3

        # prepare fat partition
        mkdir -p /mnt/sda2
        mount /dev/sda2 /mnt/sda2
        #mkdir -p /mnt/sda2/arduino/www

        umount /dev/sda?
        rm -rf /mnt/sda?

        # prepare extroot overlay on sda1
        mkdir -p /mnt/sda1
        mount /dev/sda1 /mnt/sda1
        rsync -a --exclude=/mnt/ --exclude=/www/sd /overlay/ /mnt/sda1/

        umount /dev/sda?
        rm -rf /mnt/sda?

        # update fstab
        uci add fstab mount
        uci set fstab.@mount[0].target=/overlay
        uci set fstab.@mount[0].device=/dev/sda1
        uci set fstab.@mount[0].fstype=ext4
        uci set fstab.@mount[0].enabled=1
        uci set fstab.@mount[0].enabled_fsck=0
        uci set fstab.@mount[0].options=rw,sync,noatime,nodiratime
        #uci add fstab mount
        #uci set fstab.@mount[1].target=/mnt/sda2
        #uci set fstab.@mount[1].device=/dev/sda2
        #uci set fstab.@mount[1].fstype=vfat
        #uci set fstab.@mount[1].enabled=1
        #uci add fstab swap
        #uci set fstab.@swap[0].device=/dev/sda3
        #uci set fstab.@swap[0].enabled=1
        uci commit

```
> Now edit ***/etc/config/fstab*** with the UJE_YUN info:

```

        config global
            option anon_swap '0'
            option anon_mount '0'
            option auto_swap '1'
            option auto_mount '1'
            option delay_root '5'
            option check_fs '0'

        config global 'automount'
            option from_fstab '1'
            option anon_mount '1'
            option anon_swap '0'
            option auto_swap '1'
            option auto_mount '1'
            option check_fs '0'

        config mount
            option device '/dev/sda1'
            option target '/overlay'
            option fstype 'ext4'
            option options 'rw,sync,noatime,nodiratime'
            option enabled_fsck '0'
            option enabled '1'

        config mount
            option device '/dev/sda2'
            option target '/mnt/sdafat'
            option fstype 'vfat'
            option enabled '1'

        config swap
            option device '/dev/sda3'
            option enabled '1'

```

> Reboot the Yún. The overlay should now be in place.



##<div style="background-color:#B0BFDC; padding:4px 8px 4px 20px">Links</div>

[LEDE 17.01.4 source code](https://github.com/lede-project/source/tree/v17.01.4)
[LEDE downloads](http://downloads.lede-project.org/)
[Yun cheat sheet](http://www.egrep.jp/wiki/index.php/OpenWrt_for_Arduino_Yun_cheat_sheet)
[nxhack](https://github.com/nxhack)
[OpenWRT flash layout](https://wiki.openwrt.org/doc/techref/flash.layout)
[OpenWRT cross-compile](https://wiki.openwrt.org/doc/devel/crosscompile)
[OpenWRT build](https://wiki.openwrt.org/doc/howto/build)
[OpenWRT extroot](https://wiki.openwrt.org/doc/howto/extroot)
[u-boot manual](http://ftp1.digi.com/support/documentation/90000852_K.pdf)
[Kernel 1280 requirement](https://forum.lede-project.org/t/ardiuno-yun-kernel-size-under-1280k-requirement/3948)
[Bootloader flashing "Arduino as ISP"](https://learn.sparkfun.com/tutorials/installing-an-arduino-bootloader)



