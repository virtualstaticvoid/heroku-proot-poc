# heroku-proot-poc

PoC using `proot` on Heroku

## Backstory

I maintain the opensource [Heroku R buildpack](https://github.com/virtualstaticvoid/heroku-buildpack-r). The process of deploying and running R on Heroku is fairly complex, especially since Heroku doesn't permit `apt-get` or anything requiring `root` for obvious reasons and runs a very tighly locked down Ubuntu. This has presented some unique challenges, especially since the deploy phase needs to compile packages, so need a full build environment, with further dependencies on for example gfortran, the JDK, Python etc.

Under the `cedar-14` stack I managed to work around it but with severe functional restrictions. Under the `heroku-16` stack, I managed to hack a `fakechroot` to get it working.

Now under the `heroku-18` stack Heroku have further locked down the environment so `fakechroot`, `fakeroot` and `chroot` no longer work.

I've been investigating alternatives including `udocker` which lead me to `proot` which proved promising in my local prototype testing, using the Heroku supplied `heroku/heroku:18` and `heroku/heroku:18-build` docker images. However when testing on the actual Heroku environment it fails.

## Expected Behavior

Ultimately to execute `apt-get install`.

## Actual Behavior

```
proot error: ptrace(TRACEME): Permission denied
proot error: execve("/bin/sh"): Permission denied
```

## Steps to Reproduce the Problem

[virtualstaticvoid/heroku-proot-poc](https://github.com/virtualstaticvoid/heroku-proot-poc) contains a working project to replicate the issue.

Steps as follows:

  1. You'll need a Heroku account
  2. `git clone https://github.com/virtualstaticvoid/heroku-proot-poc`
  3. `cd heroku-proot-poc`
  4. `heroku create --stack heroku-18 --buildpack https://github.com/niteoweb/heroku-buildpack-shell.git`
  5. `git push heroku master`

## Specifications

  - Proot/Care version: `5.1.0 - built-in accelerators: process_vm = yes, seccomp_filter = no`
  - Kernel version: `Linux 4.4.0-1062-aws #66-Ubuntu`
  - Host distribution: Heroku `heroku-18` stack. See [stack packages](https://devcenter.heroku.com/articles/stack-packages).
  - Guest distribution: `ubuntu-18.04-minimal-cloudimg-amd64-root`

## Command Output

```terminal
-----> Running .heroku/run.sh
++ export PATH=./bin:/usr/local/bin:/usr/bin:/bin:/tmp/codon/vendor/bin
++ PATH=./bin:/usr/local/bin:/usr/bin:/bin:/tmp/codon/vendor/bin
++ export LD_LIBRARY_PATH=./lib:
++ LD_LIBRARY_PATH=./lib:
++ export LANG=C.UTF-8
++ LANG=C.UTF-8
++ export TZ=UTC
++ TZ=UTC
++ uname --all
Linux 4a5aec0c-8d8f-43a5-948d-b995adc04e59 4.4.0-1062-aws #66-Ubuntu SMP Thu Jan 30 13:49:40 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux
++ proot --version
proot --version
 _____ _____              ___
|  __ \  __ \_____  _____|   |_
|   __/     /  _  \/  _  \    _|
|__|  |__|__\_____/\_____/\____| 5.1.0

built-in accelerators: process_vm = yes, seccomp_filter = no

Visit http://proot.me for help, bug reports, suggestions, patchs, ...
Copyright (C) 2014 STMicroelectronics, licensed under GPL v2 or later.
++ '[' '!' -f ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz ']'
++ curl -sLO https://cloud-images.ubuntu.com/minimal/releases/bionic/release/ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz
++ mkdir -p .root-fs
++ cd .root-fs
++ tar -xf ../ubuntu-18.04-minimal-cloudimg-amd64-root.tar.xz --exclude=dev
++ cd ..
++ with_proot /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get update -q'
+++ pwd
++ proot -S .root-fs -b /tmp/build_47d2521fad59fa4369c7b2a640161de1:/app -w /app /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get update -q'
proot error: ptrace(TRACEME): Permission denied
proot error: execve("/bin/bash"): Permission denied
proot info: possible causes:
  * the program is a script but its interpreter (eg. /bin/sh) was not found;
  * the program is an ELF but its interpreter (eg. ld-linux.so) was not found;
  * the program is a foreign binary but qemu was not specified;
  * qemu does not work correctly (if specified);
  * the loader was not found or doesn't work.
fatal error: see `proot --help`.
proot error: can't chmod '/tmp/proot-96-kaGksX': No such file or directory
```

## License

MIT License. Copyright (c) 2020 Chris Stefano. See LICENSE for details.
