# Maintainer: Jan Marvin Garbuszus <jan.garbuszus@rub.de>
# Contributor: Marco Pompili <aur (at) mg.odd.red>
# Contributor: Anatol Pomozov <anatol.pomozov@gmail.com>
# Contributor: Bartłomiej Piotrowski <nospam@bpiotrowski.pl>
# Contributor: Kaiting Chen <kaitocracy@gmail.com>
# Contributor: tocer <tocer.deng@gmail.com>
# Contributor: David Flemström <david.flemstrom@gmail.com>

pkgname=v8-static
pkgver=10.9.130
pkgrel=1
pkgdesc="Google's open source JavaScript and WebAssembly engine"
arch=('x86_64')
url="https://v8.dev"
license=('BSD')
depends=()
optional=('rlwrap')
makedepends=('python3' 'lld' 'git')
conflicts=()
provides=('v8')
source=("depot_tools::git+https://chromium.googlesource.com/chromium/tools/depot_tools.git")
sha256sums=('SKIP')

OUTFLD=x64.static

prepare() {

  export PATH=`pwd`/depot_tools:"$PATH"

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
    --args='cppgc_enable_young_generation=true
            dcheck_always_on=false
            is_asan=false
            is_clang=false
            is_debug=false
            is_official_build=false
            treat_warnings_as_errors=false
            use_custom_libcxx=false
            use_goma=false
            use_lld=true
            use_sysroot=false
            v8_enable_backtrace=true
            v8_enable_disassembler=true
            v8_enable_i18n_support=true
            v8_enable_object_print=true
            v8_enable_sandbox=false
            v8_enable_verify_heap=true
            v8_monolithic=true
            v8_static_library=true
            v8_use_external_startup_data=false'

  # Fixes bug in generate_shim_headers.py that fails to create these dirs
  msg2 "Adding icu missing folders"
  mkdir -p "$OUTFLD/gen/shim_headers/icuuc_shim/third_party/icu/source/common/unicode/"
  mkdir -p "$OUTFLD/gen/shim_headers/icui18n_shim/third_party/icu/source/i18n/unicode/"

}

build() {
  export PATH=`pwd`/depot_tools:"$PATH"

  cd $srcdir/v8

  msg2 "Building"
  ninja -C $OUTFLD
}

check() {
  cd $srcdir/v8

  msg2 "Testing"
  tools/run-tests.py --no-presubmit \
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
