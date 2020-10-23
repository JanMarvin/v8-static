# Maintainer: Jan Marvin Garbuszus <jan.garbuszus@rub.de>
# Contributor: Marco Pompili <aur (at) mg.odd.red>
# Contributor: Anatol Pomozov <anatol.pomozov@gmail.com>
# Contributor: Bartłomiej Piotrowski <nospam@bpiotrowski.pl>
# Contributor: Kaiting Chen <kaitocracy@gmail.com>
# Contributor: tocer <tocer.deng@gmail.com>
# Contributor: David Flemström <david.flemstrom@gmail.com>

pkgname=v8-static
pkgver=8.6.395.17
pkgrel=1
pkgdesc="Google's open source JavaScript and WebAssembly engine"
arch=('x86_64')
url="https://v8.dev"
license=('BSD')
depends=()
optional=('rlwrap')
makedepends=('python2' 'python3' 'git')
conflicts=()
provides=('v8')
source=("depot_tools::git+https://chromium.googlesource.com/chromium/tools/depot_tools.git")
sha256sums=('SKIP')

OUTFLD=x86.static

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
    --args='v8_monolithic=true
            v8_static_library=true
            is_clang=false
            is_asan=false
            use_gold=false
            is_debug=false
            is_official_build=false
            treat_warnings_as_errors=false
            v8_enable_i18n_support=true
            v8_use_external_startup_data=false
            use_custom_libcxx=false
            use_sysroot=false'

}

build() {
  export PATH=`pwd`/depot_tools:"$PATH"
  export GYP_GENERATORS=ninja

  cd $srcdir/v8

  msg2 "Building, this will take a while..."
  ninja -C $OUTFLD
}

check() {
  cd $srcdir/v8

  msg2 "Testing, this will also take a while..."
  python2  tools/run-tests.py --no-presubmit \
                              --outdir=$OUTFLD \
                              --arch="x64" || true
}

package() {
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

# vim:set ts=2 sw=2 et:
