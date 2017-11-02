#
# Copyright (C) 2009-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/UJE_YUN
       NAME:=[UJE]Yun.FPU_EMU
       PACKAGES:=kmod-usb-core kmod-usb2 kmod-usb-ledtrig-usbport kmod-usb-storage kmod-fs-ext4 e2fsprogs
endef

define Profile/UJE_YUN/Description
       Package set optimized for the [UJE]Yun.
       The kernel 4.4.92 is compiled with MIPS_FPU_EMULATOR enabled.
endef

$(eval $(call Profile,UJE_YUN))
