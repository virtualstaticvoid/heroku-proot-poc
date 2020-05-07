#!/bin/bash

set -e # fail fast
set -x # debug

function with_proot() {

  # proot -S .root-fs -b "$(pwd):/app" -w /app "$@"
  # proot -S .root-fs -b "$(pwd):/app" -w /app -v 9 "$@"

  # as per recommended_su_bindings
  # https://github.com/proot-me/proot/blob/master/src/cli/proot.h#L36

  # NB: excludes $HOME since == /app on Heroku
  # and want the build directory to "mount" as /app inside the chroot

  proot -r .root-fs \
        -b "/etc/host.conf" \
        -b "/etc/hosts" \
        -b "/etc/nsswitch.conf" \
        -b "/etc/resolv.conf" \
        -b "/dev/" \
        -b "/sys/" \
        -b "/proc/" \
        -b "/tmp/" \
        -b "$(pwd):/app" \
        -0 \
        -v 9 \
        -w /app "$@"

}

#
# pertinent runtime layout:
#
# <arbitrary-directory>  - /tmp/build_<GUID> - at slug compile
#  │                       /app              - at "runtime"
#  ├── bin
#  │   └── proot
#  ├── lib
#  │   ├── libtalloc.so.2 -> libtalloc.so.2.1.10
#  │   └── libtalloc.so.2.1.10
#  └── .heroku
#      └── run.sh (this script)
#
# all commands executed from <arbitrary-directory>
#

# debug info:
( set -o posix; set )

export PATH="$(pwd)/bin:/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:$PATH"
export LD_LIBRARY_PATH="$(pwd)/lib:$LD_LIBRARY_PATH"
export LANG=C.UTF-8
export TZ=UTC

# debug info:
uname --all
proot --version

if [ ! -f ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz ]; then
  curl -sLO https://cloud-images.ubuntu.com/minimal/releases/bionic/release/ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz
fi

mkdir -p .root-fs
cd .root-fs
tar -xf ../ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz --exclude=dev
cd ..

with_proot echo "Hello World from proot"
with_proot /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get update -q"
with_proot /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install -qy r-base"
with_proot R --no-save --quiet --slave --file=/app/test.R
