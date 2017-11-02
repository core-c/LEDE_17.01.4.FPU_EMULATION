# UJE_YUN firmware 17.01.4.FPU_EMULATION

## Description

Adapted for the Arduino Yún.
U-boot 1.1.5 with 'saveenv' support.
LEDE 17.01.4 with FPU_EMULATION.

## Usage

Create and enter your LEDE folder,
the location where you want the LEDE source-code placed.
```
  mkdir /usr/src/LEDE
  cd /usr/src/LEDE
```

Copy the ***SETUP*** folder to your LEDE folder.
```
  cp -R /from/here/SETUP .
```
>  Example: If your path_to_LEDE is ***/usr/src/LEDE***
>           you will end up with this: ***/usr/src/LEDE/SETUP***

Download the LEDE 17.01.4 source-code.
```
  git clone --depth=1 --branch v17.01.4 --single-branch https://git.lede-project.org/source.git
```
>  Now you should have a ***source*** folder created.

Enter the LEDE ***source*** folder.
```
  cd source
```

Copy the Yún specific ***files*** folder to your LEDE ***source*** folder.
```
  cp -R ../SETUP/files .
```

Overwrite existing LEDE configuration files with the UJE_YUN config files.
```
cp ../SETUP/source____.config .config
cp ../SETUP/source____feeds.conf.default feeds.conf.default
cp ../SETUP/source_target_linux_ar7_image____Makefile target/linux/ar7/image/Makefile
cp ../SETUP/source_target_linux_ar71xx____config-4.4 target/linux/ar71xx/config-4.4
cp ../SETUP/source_target_linux_ar71xx_image____generic.mk target/linux/ar71xx/image/generic.mk
cp ../SETUP/source_target_linux_ar71xx_image____legacy.mk target/linux/ar71xx/image/legacy.mk
cp ../SETUP/source_target_linux_ar71xx_image____legacy-devices.mk target/linux/ar71xx/image/legacy-devices.mk
```

Take a look at the UJE_YUN configuration settings.
```
  make kernel_menuconfig
  make menuconfig
```
>  When you exit kernel_menuconfig and menuconfig,
>  if asked to write the config, confirm with YES.

Now it is time to perform the cross-compile.
```
  make
```

On a succesful compilation you will find the firmware files at this location:
  ***<path_to_your_LEDE>/source/bin/targets/ar71xx/generic***




  
  