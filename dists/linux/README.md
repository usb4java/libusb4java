Linux Build
===========

This build script automatically compiles the native libusb4java library for the given architecture. It is primarily
written to be used on a X86-64 Debian machine but may work on other systems as well.

The first build for a specific architecture takes a long time because a matching Docker image is created first. This
image is based on Debian Stretch and is filled with all necessary tools and libraries to build libusb4java. The
Docker image is cached so the next build for the same architecture will be much faster.


## Requirements

The following packages must be installed before running the build script:

    # apt install binfmt-support qemu-user-static

[Docker] must be installed by following the official installation instructions.

After installing Docker it is recommended to put your user into the docker group and logout and in again to apply the
change. Then you are able to use docker without root privileges.


## Parameters

The first parameter of the build script defines the target platform architecture. This is for example `x86`, `x86-64`,
`arm` or `aarch64`. The architecture naming convention of usb4java follows the one of the [Java Native Access] project.

The second parameter is optional and defines the static qemu binary which is necessary for cross compiling.


## Example usages

Build a X86 (32 bit) library on a X86 or X86-64 host system:

    $ ./build x86

Build a X86-64 library on a X86-64 host system:

    $ ./build x86-64

Build a ARM-HF (32 bit) library:

    $ ./build arm /usr/bin/qemu-arm-static

Build a AARCH64 (ARM 64 Bit) library:

    $ ./build aarch64 /usr/bin/qemu-aarch64-static

In theory this works for many more architectures as long as there is a Debian Stretch docker image for this
architecture and the architecture is supported by qemu. New entries in the architecture mapping in the build script
might be needed in case the java architecture name differs from the Debian architecture name in the docker library.


## Some notes about Docker

### Disable bridge networking

If you don't need Docker for anything else and you don't like Docker's default behavior of creating bridge networking
devices and firewall rules then you might want to disable all this by creating the config file `/etc/docker/daemon.json`
with the following content:

    {
        "bridge": "none",
        "iptables": false,
        "ip-masq": false,
        "ip-forward": false
    }

Run `sudo systemctl restart docker` to apply the changes. The libusb4java build script uses host networking which
doesn't need bridge network devices.


### Cleaning up

All the created Docker images uses a lot of disk space. You can remove them with `docker system prune -a`.


## Known issues

While the build script is able to create a binary for the ARM architecture this will not work on a Raspberry
Pi 1.  Would be nice to get it running, I tried for days, but I didn't succeed.  That's why there is a special build
script for ARM which uses the Raspberry Pi cross compiler toolchain.

[Java Native Access]: https://github.com/java-native-access/jna/tree/master/dist/
[Docker]: https://docs.docker.com/install/linux/docker-ce/debian/
