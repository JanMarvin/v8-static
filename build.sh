#!/bin/bash

# Maintainer: Jan Marvin Garbuszus <jan.garbuszus@rub.de>

# requires
# * fakeroot (for build step)
# * git (for fetch, possibly curl or wget too)
# * python2 (for check)
# * python3
# * tar
# * coreutils

pkgname=v8-static
provides=v8
pkgver=8.6.395.17
pkgrel=1
pkgdesc="Google's open source JavaScript and WebAssembly engine"
source="https://chromium.googlesource.com/chromium/tools/depot_tools.git"

crnt_arch="x64" # x86 ppc ppc64 arm arm64 mips mips64 mipsel mips64el s390 s390x
trgt_arch="x64"
trgt_os="linux" # mac win android fuchsia ios 

OUTFLD="$arch.static"

# get depot_tools
if [ ! -d "depot_tools" ]; then
   git clone $source
else
   git pull 
fi

# keep the Arch Linux pkgbuild logic

maindir=`pwd`
srcdir=$maindir/src
pkgdir=$maindir/pkg

mkdir -p $srcdir
mkdir -p $pkgdir

if [ -d "$srcdir/depot_tools" ]; then
  echo "cleanup"
  rm -rf "$srcdir/depot_tools"
fi
ln -s $maindir/depot_tools/ $srcdir/depot_tools

function msg {
  echo -e "\e[34m\e[1m$1\e[0m"
}

function msg2 {
  echo -e "\e[32m$1\e[0m"
}



## prepare step

msg "prepare" 
cd $srcdir
prepare() {


  export PATH=`pwd`/depot_tools:"$PATH"
  export GYP_GENERATORS=ninja


  if [ ! -d "v8" ]; then
    msg2 "Fetching V8 code"
    yes | fetch v8
  fi

  cd $srcdir/v8

  msg2 "Reset repository"
  git reset --hard

  msg2 "Syncing, this can take a while..."
  gclient sync -D --force --reset
  gclient sync --revision ${pkgver}
 
  msg2 "Running GN..."
  gn gen $OUTFLD \
    -vv --fail-on-unused-args \
    --args="v8_monolithic=true
            v8_static_library=true
            v8_multi_arch_build=false
            v8_current_cpu=\"$crnt_arch\"
            v8_target_cpu=\"$trgt_arch\"
            target_os=\"$trgt_os\"
            is_clang=false
            is_asan=false
            use_gold=false
            is_debug=false
            is_official_build=false
            treat_warnings_as_errors=false
            v8_enable_i18n_support=true
            v8_use_external_startup_data=false
            use_custom_libcxx=false
            use_sysroot=false"
  
}

prepare

## end prepare


cd $srcdir
## build step
msg "build"
fakeroot -- bash <<- EOF

build() { 

  export PATH=`pwd`/depot_tools:"$PATH"
  export GYP_GENERATORS=ninja

  cd $srcdir/v8

  msg2 "Building, this will take a while..."
  ninja -C $OUTFLD
}

build

EOF
## end build


## check step
msg "check"
fakeroot -- bash <<- EOF

check() {
  
  cd $srcdir/v8
  
  msg2 "Testing, this will also take a while..."
  python2  tools/run-tests.py --no-presubmit \
                              --outdir=$OUTFLD \
                              --arch=$target_arch || true
}

check

EOF
## end check


## package step
msg "package"
fakeroot -- bash  <<- EOF

package_me() {

  # keep only the statically linked monolith library and the header files

  cd $srcdir/v8

  install -d ${pkgdir}v8

  install -d ${pkgdir}/v8/lib
  install -Dm755 $OUTFLD/obj/libv8_monolith.a ${pkgdir}/v8/lib/libv8_monolith.a

  install -d ${pkgdir}/v8/include
  install -Dm644 include/*.h ${pkgdir}/v8/include
  
  install -d ${pkgdir}/v8/include/cppgc
  install -Dm644 include/cppgc/*.h ${pkgdir}/v8/include/cppgc
  
  install -d ${pkgdir}/v8/include/libplatform
  install -Dm644 include/libplatform/*.h ${pkgdir}/v8/include/libplatform

  install -d ${pkgdir}/v8/lic/
  install -m644 LICENSE* ${pkgdir}/v8/lic/

}

package_me

EOF

# create the tar-ball
cd $maindir
tar cJf "v8-$trgt_arch-$pkgver.tar.xz" -C $pkgdir v8

## end package

# vim:set ts=2 sw=2 et:
