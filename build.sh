#!/bin/bash -ex
# !/bin/sh

BUILD_DATE = `date +%Y%m%d-%H%M%S`
FIRST_TIME = false
MY_COL = "\e[48;5;232m;38;5;209m"
DEF_COL = "\e[0m"

#                   path (relative to 'source')             file                 clarity prefix
declare -a UJE0 = (""                                      ".config"            "source____");
declare -a UJE1 = (""                                      "feeds.conf.default" "source____");
declare -a UJE2 = ("target/linux/ar7/image/"               "Makefile"           "source_target_linux_ar7_image____");
declare -a UJE3 = ("target/linux/ar71xx/"                  "config-4.4"         "source_target_linux_ar71xx____");
declare -a UJE4 = ("target/linux/ar71xx/generic/profiles/" "uje_yun.mk"         "source_target_linux_ar71xx_generic_profiles____");
declare -a UJE5 = ("target/linux/ar71xx/image/"            "generic.mk"         "source_target_linux_ar71xx_image____");
declare -a UJE6 = ("target/linux/ar71xx/image/"            "legacy.mk"          "source_target_linux_ar71xx_image____");
declare -a UJE7 = ("target/linux/ar71xx/image/"            "legacy-devices.mk"  "source_target_linux_ar71xx_image____");

# FUNCTION: COPY UJE_YUN CONFIG
# ARGUMENTS: $1 = from path, $2 = to path, $3-$6 = indexes into array UJE[x], $7 = suffix extension
function copy_uje_yun_config {
    echo -en "${MY_COL}Apply UJE_YUN config files..${DEF_COL}"
	cp $1${UJE0[$3]}${UJE0[$4]} $2${UJE0[$5]}${UJE0[$6]}$7 > /dev/null
	cp $1${UJE1[$3]}${UJE1[$4]} $2${UJE1[$5]}${UJE1[$6]}$7 > /dev/null
	cp $1${UJE2[$3]}${UJE2[$4]} $2${UJE2[$5]}${UJE2[$6]}$7 > /dev/null
	cp $1${UJE3[$3]}${UJE3[$4]} $2${UJE3[$5]}${UJE3[$6]}$7 > /dev/null
	cp $1${UJE4[$3]}${UJE4[$4]} $2${UJE4[$5]}${UJE4[$6]}$7 > /dev/null
	cp $1${UJE5[$3]}${UJE5[$4]} $2${UJE5[$5]}${UJE5[$6]}$7 > /dev/null
	cp $1${UJE6[$3]}${UJE6[$4]} $2${UJE6[$5]}${UJE6[$6]}$7 > /dev/null
	cp $1${UJE7[$3]}${UJE7[$4]} $2${UJE7[$5]}${UJE7[$6]}$7 > /dev/null
}

# UJE_YUN SETUP DIRECTORY MUST EXIST
echo -en "${MY_COL}Check UJE_YUN SETUP..${DEF_COL}"
if [ ! -e 'SETUP' ]; then
    echo "ERROR: Missing SETUP directory, containing the UJE_YUN config files."
	exit 0
fi
# UJE_YUN CONFIG FILES MUST EXIST
if [ ! -e 'SETUP/${UJE0[2]}${UJE0[1]}' ]; then
    echo "ERROR: Missing UJE_YUN file: SETUP/${UJE0[2]}${UJE0[1]}"
	exit 0
fi
if [ ! -e 'SETUP/${UJE1[2]}${UJE1[1]}' ]; then
    echo "ERROR: Missing UJE_YUN file: SETUP/${UJE1[2]}${UJE1[1]}"
	exit 0
fi
if [ ! -e 'SETUP/${UJE2[2]}${UJE2[1]}' ]; then
    echo "ERROR: Missing UJE_YUN file: SETUP/${UJE2[2]}${UJE2[1]}"
	exit 0
fi
if [ ! -e 'SETUP/${UJE3[2]}${UJE3[1]}' ]; then
    echo "ERROR: Missing UJE_YUN file: SETUP/${UJE3[2]}${UJE3[1]}"
	exit 0
fi
if [ ! -e 'SETUP/${UJE4[2]}${UJE4[1]}' ]; then
    echo "ERROR: Missing UJE_YUN file: SETUP/${UJE4[2]}${UJE4[1]}"
	exit 0
fi
if [ ! -e 'SETUP/${UJE5[2]}${UJE5[1]}' ]; then
    echo "ERROR: Missing UJE_YUN file: SETUP/${UJE5[2]}${UJE5[1]}"
	exit 0
fi
if [ ! -e 'SETUP/${UJE6[2]}${UJE6[1]}' ]; then
    echo "ERROR: Missing UJE_YUN file: SETUP/${UJE6[2]}${UJE6[1]}"
	exit 0
fi
if [ ! -e 'SETUP/${UJE7[2]}${UJE7[1]}' ]; then
    echo "ERROR: Missing UJE_YUN file: SETUP/${UJE7[2]}${UJE7[1]}"
	exit 0
fi

# YUN SPECIFIC FILES MUST EXIST
if [ ! -e 'SETUP/files' ]; then
    echo "ERROR: Missing SETUP/files directory, containing the Yun specific files."
	exit 0
fi

# CHECK BACKUP DIRECTORIES
echo -en "${MY_COL}Check UJE_YUN BACKUP directories..${DEF_COL}"
if [ ! -e 'BACKUP' ]; then
    mkdir BACKUP > /dev/null
fi
if [ ! -e 'BACKUP/dl' ]; then
    mkdir BACKUP/dl > /dev/null
fi

# CHECK source DIRECTORY for the LEDE git source code
echo -en "${MY_COL}Check LEDE 17.01.4 source code..${DEF_COL}"
if [ ! -e 'source' ]; then
    FIRST_TIME = true
    # there is no source code. download it..
    echo "Downloading LEDE 17.01.4 source code.."
    git clone --depth=1 --branch v17.01.4 --single-branch https://git.lede-project.org/source.git
    if [ ! -e 'source' ]; then
	    echo "ERROR: The LEDE 17.01.4 source code could not be downloaded."
        exit 0
    fi
fi

# ENTER THE source DIRECTORY
echo -en "${MY_COL}Enter the source directory..${DEF_COL}"
cd source

# BACKUP LOCAL BUILD KEY
echo -en "${MY_COL}Backup local build key..${DEF_COL}"
if [ -e 'key-build' ]; then
    cp -n key-build ../BACKUP/ > /dev/null
    cp key-build ../BACKUP/key-build.${BUILD_DATE}-$$ > /dev/null
fi
if [ -e 'key-build.pub' ]; then
    cp -n key-build.pub ../BACKUP/ > /dev/null
    cp key-build.pub ../BACKUP/key-build.pub.${BUILD_DATE}-$$ > /dev/null
fi

# BACKUP DL DIRECTORY
echo -en "${MY_COL}Backup download directory..${DEF_COL}"
if [ -e 'dl' ]; then
    cp dl/* ../BACKUP/dl/* > /dev/null
fi

# BACKUP EXISTING CONFIG FILES
echo -en "${MY_COL}Backup config files..${DEF_COL}"
# ORIGINAL CONFIG FILES MUST EXIST
if [ ! -e '${UJE0[0]}${UJE0[1]}' ]; then
    echo "ERROR: Missing config file: ${UJE0[0]}${UJE0[1]}"
	exit 0
fi
if [ ! -e '${UJE1[0]}${UJE1[1]}' ]; then
    echo "ERROR: Missing config file: ${UJE1[0]}${UJE1[1]}"
	exit 0
fi
if [ ! -e '${UJE2[0]}${UJE2[1]}' ]; then
    echo "ERROR: Missing config file: ${UJE2[0]}${UJE2[1]}"
	exit 0
fi
if [ ! -e '${UJE3[0]}${UJE3[1]}' ]; then
    echo "ERROR: Missing config file: ${UJE3[0]}${UJE3[1]}"
	exit 0
fi
if [ ! -e '${UJE4[0]}${UJE4[1]}' ]; then
    echo "ERROR: Missing config file: ${UJE4[0]}${UJE4[1]}"
	exit 0
fi
if [ ! -e '${UJE5[0]}${UJE5[1]}' ]; then
    echo "ERROR: Missing config file: ${UJE5[0]}${UJE5[1]}"
	exit 0
fi
if [ ! -e '${UJE6[0]}${UJE6[1]}' ]; then
    echo "ERROR: Missing config file: ${UJE6[0]}${UJE6[1]}"
	exit 0
fi
if [ ! -e '${UJE7[0]}${UJE7[1]}' ]; then
    echo "ERROR: Missing config file: ${UJE7[0]}${UJE7[1]}"
	exit 0
fi
copy_uje_yun_config "" "../BACKUP/" 0 1 2 1 ""

# APPLY UJE_YUN CONFIG
copy_uje_yun_config "../SETUP/" "" 2 1 0 1 ""

# CHECK FIRST TIME INIT
echo -en "${MY_COL}Check first run..${DEF_COL}"
if [ ${FIRST_TIME} -eq true ]; then
    # CLEAN
    make clean
    make dirclean
    make distclean
	make kernel_menuconfig
	make menuconfig
fi

# RESTORE DL DIRECTORY
echo -en "${MY_COL}Restore download directory..${DEF_COL}"
if [ -e '../BACKUP/dl' ]; then
    cp ../BACKUP/dl/* dl/* > /dev/null
fi

#RESTORE LOCAL BUILD KEY
echo -en "${MY_COL}Restore local build key..${DEF_COL}"
if [ -e '../BACKUP/key-build' ]; then
    cp ../BACKUP/key-build . > /dev/null
fi
if [ -e '../BACKUP/key-build.pub' ]; then
    cp ../BACKUP/key-build.pub . > /dev/null
fi

# APPLY UJE_YUN CONFIG   (moet dat na elke make kernel_menuconfig?? kan iig. geen kwaad om het nu nog eens te doen.      test eerst..)
copy_uje_yun_config "../SETUP/" "" 2 1 0 1 ""

# PREPARE YUN SPECIFIC FILES
echo -en "${MY_COL}Prepare Yun specific files..${DEF_COL}"
if [ -e '../SETUP/files' ]; then
    rm -R ../SETUP/files/* > /dev/null
	cp -R ../SETUP/files . > /dev/null
fi

# PACKAGE FEEDS
echo -en "${MY_COL}Setup package feeds..${DEF_COL}"
if [ ${vFirstTime} -eq true ]; then
    # FEEDS
    ./scripts/feeds uninstall -a
    rm -rf feeds > /dev/null
    ./scripts/feeds update -a
    ./scripts/feeds install -a

    # DELETE OPENWRT NODE PACKAGES
    rm  ./package/feeds/packages/node > /dev/null
    rm  ./package/feeds/packages/node-arduino-firmata > /dev/null
    rm  ./package/feeds/packages/node-cylon > /dev/null
    rm  ./package/feeds/packages/node-hid > /dev/null
    rm  ./package/feeds/packages/node-serialport > /dev/null

    # INSTALL CUSTOM UJE_YUN NODE PACKAGES
    #./scripts/feeds install -a -p node

    # ik weet nog niet wat dit doet... checken c
    make oldconfig
fi

# REMOVE EXISTING COMPILED FILES
echo -en "${MY_COL}Remove old compiled firmware bins..${DEF_COL}"
if [ -e 'bin/targets/ar71xx/generic' ]; then
    rm bin/targets/ar71xx/generic/* > /dev/null
fi

# START CROSS-COMPILE
echo -en "${MY_COL}Cross-Compiling..${DEF_COL}"
if [ $# -eq 1 ] then
    case "$1" in
        -1)  make -j1;;
        -4)  make -j4;;
        -v)  make -j1 V=s;;
		*)   make;;
    esac
else
    make -j4
fi

# CLEAN UP FOR UNUSED FILES
echo -en "${MY_COL}Clean up..${DEF_COL}"
if [ -e 'bin/targets/ar71xx/generic/lede-ar71xx-generic-vmlinux.bin' ]; then
    rm bin/targets/ar71xx/generic/lede-ar71xx-generic-vmlinux.bin > /dev/null
fi
if [ -e 'bin/targets/ar71xx/generic/lede-ar71xx-generic-vmlinux.elf' ]; then
    rm bin/targets/ar71xx/generic/lede-ar71xx-generic-vmlinux.elf > /dev/null
fi
if [ -e 'bin/targets/ar71xx/generic/lede-ar71xx-generic-vmlinux.lzma' ]; then
    rm bin/targets/ar71xx/generic/lede-ar71xx-generic-vmlinux.lzma > /dev/null
fi
if [ -e 'bin/targets/ar71xx/generic/lede-ar71xx-generic-vmlinux-lzma.elf' ]; then
    rm bin/targets/ar71xx/generic/lede-ar71xx-generic-vmlinux-lzma.elf > /dev/null
fi

# CHECK SUCCESFUL COMPILE
if [ -e 'bin/targets/ar71xx/generic/lede-ar71xx-generic-arduino-yun-squashfs-sysupgrade.bin' ]; then
    # backup lastworking configuration
    copy_uje_yun_config "" "../BACKUP/" 0 1 2 1 ".lastworking"
    echo -en "${MY_COL}========= COMPILE SUCCESSFUL =========${DEF_COL}"
	ls bin/targets/ar71xx/generic
else
    echo -en "${MY_COL}======= COMPILE NOT SUCCESSFUL =======${DEF_COL}"
fi
