# UJE_YUN firmware 17.01.4.FPU_EMULATION

## Description

Adapted for the Arduino Yún.
U-boot 1.1.5 with 'saveenv' support.
LEDE 17.01.4 with FPU_EMULATION.


## Creating a cross-compiled custom firmware

####Create and enter your LEDE folder
```

  mkdir /usr/src/LEDE
  cd /usr/src/LEDE

```
This will become the location where you want the LEDE source-code placed.


####Copy the ***SETUP*** folder to your LEDE folder
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


####Enter the LEDE ***source*** folder
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

  ls /usr/src/LEDE/source/bin/targets/ar71xx/generic/*

```


## Flashing the firmware

Depending on the size of your compiled kernel & rootfs/squash,
you probably need to adjust the bootloader of the Yún
in order to be able to   ...........blahblahetcetc
    TODO:  finish this text :)
  
  
Here's an example of the UJE_YUN flash layout:
```

                    ____________________ ____________________ ____________________ ____________________ ____________________ 
                   |                    |                    |                    |                    |                    |
                   | u-boot             | u-boot-env         | kernel             | rootfs             |   art              |
             start |        0x9F000000  |        0x9F040000  |        0x9F050000  |        0x9F170000  |        0x9FFF0000  |
            length | 256k        40000  | 64k         10000  | 1150k      11F800  | 14720k     E60000  | 64k         10000  |
        pad-to 64k |                    |                    | 1152k      120000  |            E60000  |                    |
               end |        0x9F040000  |        0x9F050000  |        0x9F170000  |        0x9FFD0000  |        0xA0000000  |
                   |                    |                    |                    | can grow   +20000  |                    |
                   |                    |                    |                    | max    0x9FFF0000  |                    |
                   |                    |                    |                    |                    |                    |
                   |                    |                    | padded kernel:     | FF0000 - 170000 =  |                    |
          mtdparts | 256k(u-boot)ro     | 64k(u-boot-env)    | 1152k(kernel)      | 14848k(rootfs)     | 64k(art)ro         |
                   |                    |                    |                    |                    |                    |
          FW flash |                    |                    | erase  .  +120000  | erase  .  +E80000  |                    |
                   |                    |                    | cp.b . . filesize  | cp.b . . filesize  |                    |
                   |____________________|____________________|____________________|____________________|____________________|

```



