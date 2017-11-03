# UJE_YUN firmware 17.01.4.FPU_EMULATION



## Description

- Firmware specially adapted for the Arduino Yún.
- U-boot 1.1.5 Bootloader, with 'saveenv' support.
- LEDE 17.01.4, with FPU_EMULATION (needed for NodeJS).



## Creating a cross-compiled custom firmware

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


####Take a look at the UJE_YUN configuration settings
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



## Flashing the firmware

####UJE_YUN changes to original LEDE firmware
We dropped the use of the NVRAM partition since it it not used at all on a Yún. The resulting extra 64k memory raise the maximum size of the UJE_YUN firmware to 16000k.
We also decided to break with the Yún tradition of firmware memory arrangement. The UJE_YUN kernel always boots from memory address 0x9f050000, and the rootfs is located behind the kernel. The other flash-partitions are left at their default locations.
The UJE_YUN flash memory arrangement looks like this:
- u-boot 1.1.5 bootloader, starts at address 0x9F000000, 256k is reserved
- u-boot-env, starts at address 0x9F040000, size is 64k
- UJE_YUN firmware (kernel+rootfs), starts at address 0x9F050000, 16000k is reserved
- art (Atheros Radio Test), starts at address 0x9Fff0000, size is 64k
The UJE_YUN firmware maximum address space is 16000k. The firmware consists of a kernel and a rootfs. The combined size of kernel+rootfs can never exceed 16000k.
You can however use any size kernel. Say for example, you have compiled a 2048k kernel. This means that your rootfs can have a maximum size of 16000k - 2048k = 13952k. The individual sizes of kernel & rootfs do not matter: It's the combined size of the firmware that's important. In the end, all must fit in the 16M flash of the Atheros AR9330.

####Kernel memory alignment & padding
Flash memory can only be programmed in blocks of 64k, and there are 256 of those blocks available in the 16M flash space of the Yún.
In hexadecimal notation 64k = 0x10000. This means that start-addresses must always be multiples of 64k.
The UJE_YUN kernel start-address is fixed at 0x9F050000; No problem there. 0x50000 is a 64k multiple.
However, when allocating the flash-partition for the kernel, the actual kernel size is important. While you can partly fill a flash memory-block, you can only allocate per full block. If you have compiled a kernel that has a size that is not a 64k multiple, (for example 1150k), you need to pad the size to the next 64k boundry (which wil be 1152k for the example kernel).
In practice, when you would flash the 1150k example kernel, you would have to allocate 0x120000 bytes (=1152k), and write the 1150k kernel file.
In u-boot you would execute the following commands to flash that kernel correctly:

```

  ubootprompt>tftp 0x80060000 your_1150k_kernel_file.bin
  ubootprompt>erase 0x9f050000 +120000
  ubootprompt>cp.b $fileaddr 0x9f050000 $filesize;

```

####Rootfs memory alignment & padding

Once you know your padded-to-64k kernel size, you can calculate the remaining memory space for the rootfs.
The UJE_YUN total firmware size is always fixed to be 16000k.
In our example with the 1150k kernel file, the padded size will be 1152k (0x120000).
That leaves space for a 16000k - 1152k = 14848k.
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


Here's an example of an UJE_YUN flash layout:
```

                    ____________________ ____________________ ____________________ ____________________ ____________________ 
                   |                    |                    |                    |                    |                    |
                   | u-boot             | u-boot-env         | kernel             | rootfs             |   art              |
             start |        0x9F000000  |        0x9F040000  |        0x9F050000  |        0x9F170000  |        0x9FFF0000  |
            length | 256k        40000  | 64k         10000  | 1150k      11F800  | 14720k     E60000  | 64k         10000  |
        pad-to 64k |                    |                    | 1152k      120000  |            E60000  |                    |
               end |        0x9F040000  |        0x9F050000  |        0x9F170000  |        0x9FFD0000  |        0xA0000000  |
                   |                    |                    |                    | pad-to-max +20000  |                    |
                   |                    |                    |                    | max    0x9FFF0000  |                    |
                   |                    |                    |                    |                    |                    |
                   |                    |                    | padded kernel:     | FF0000 - 170000 =  |                    |
          mtdparts | 256k(u-boot)ro     | 64k(u-boot-env)    | 1152k(kernel)      | 14848k(rootfs)     | 64k(art)ro         |
                   |                    |                    |                    |                    |                    |
          FW flash |                    |                    | erase  .  +120000  | erase  .  +E80000  |                    |
                   |                    |                    | cp.b . . filesize  | cp.b . . filesize  |                    |
                   |____________________|____________________|____________________|____________________|____________________|

```
>  Note: This is just an example. The numbers may vary with your own compiled firmware sizes.




