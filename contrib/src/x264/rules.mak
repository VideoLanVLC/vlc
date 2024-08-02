# x264

X264_HASH := e067ab0b530395f90b578f6d05ab0a225e2efdf9
X264_VERSION := $(X264_HASH)
X264_GITURL := https://code.videolan.org/videolan/x264.git

ifdef BUILD_ENCODERS
ifdef GPL
ifndef HAVE_WINSTORE # FIXME x264 build system claims it needs MSVC to build for WinRT
PKGS += x264
endif
endif
endif

ifeq ($(call need_pkg,"x264 >= 0.148"),)
PKGS_FOUND += x264
endif

ifeq ($(call need_pkg,"x264 >= 0.153"),)
PKGS_FOUND += x26410b
endif

PKGS_ALL += x26410b

X264CONF = \
	--disable-avs \
	--disable-lavf \
	--disable-cli \
	--disable-ffms \
	--disable-opencl
ifndef HAVE_WIN32
X264CONF += --enable-pic
endif
ifdef HAVE_CROSS_COMPILE
ifndef HAVE_DARWIN_OS
X264CONF += --cross-prefix="$(HOST)-"
endif
ifdef HAVE_ANDROID
X264CONF += --cross-prefix="$(subst ar,,$(AR))"
# broken text relocations
ifeq ($(ANDROID_ABI), x86)
X264CONF += --disable-asm
endif
endif
endif

$(TARBALLS)/x264-$(X264_VERSION).tar.xz:
	$(call download_git,$(X264_GITURL),,$(X264_HASH))

.sum-x26410b: .sum-x264
	touch $@

.sum-x264: x264-$(X264_VERSION).tar.xz

x264 x26410b: %: x264-$(X264_VERSION).tar.xz .sum-%
	$(UNPACK)
	$(call update_autoconfig,.)
	$(APPLY) $(SRC)/x264/x264-winstore.patch
	$(APPLY) $(SRC)/x264/0001-osdep-use-direct-path-to-internal-x264.h.patch
	$(APPLY) $(SRC)/x264/0001-configure-set-_FILE_OFFSET_BITS-to-detect-fseeko.patch
	$(MOVE)

.x264: x264
	$(REQUIRE_GPL)
	$(MAKEBUILDDIR)
	$(MAKECONFIGURE) $(X264CONF)
	# make dummy dependency file
	touch $(BUILD_DIR)/.depend
	+$(MAKEBUILD)
	+$(MAKEBUILD) install
	touch $@

.x26410b: .x264
	touch $@
