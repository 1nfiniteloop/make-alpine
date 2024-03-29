# make-alpine

This project contains a tool-set for building a customized and fully prepared
system-installation of alpine linux, for any target architecture. The purpose is
to minimize, or completely avoid installation steps on the target machine itself.
The project mainly targets Raspberry Pi but it's developed with in mind to be
flexible and modular. The tool-set uses a docker-container as build-environment
for an easy setup and build process.

Building alpine-linux for a different architecture than the build-host (e.g.
for Raspberry Pi) requires some kind of emulation. Docker support this through
the Linux kernel-feature *binfmt_misc* and qemu-static tools to run other
architectures. A good introduction on docker and emulating other architectures
is available @ <https://mirailabs.io/blog/multiarch-docker-with-buildx/>.

Several projects exist to build alpine-linux from scratch, see references
below. Unfortunately none fitted all the needs, and reusing parts or base this
on existing projects turned out to be challenging. The projects listed below has
however been a great reference.

## Usage

### Preparation

Activate binfmt_misc and qemu-static emulation for running containers with
foreign architectures:

    docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3

**Note:** This is not persistent during reboots.

### Create build-environment for armv7

Create the build environment for alpine-linux, in this example for target
architecture arm32v7:

    docker buildx build --build-arg ARCH=arm/v7 --tag make-alpine:arm32v7 .

### Build your alpine-linux

This tool-set contains several configurations which is combined to build a
customized alpine-linux distro. Each configuration is a script which runs inside
a chrooted file system. Each configuration has optionally a set of static files
(overlays), see `config/`.

The main script `make-alpine` creates a raw image with a separate
boot-partition. The image is ready to be directly coped onto the SD-card. Below
is an example of a build with networking, ssh-access and docker.

Build alpine-linux:

    docker run \
      --name make-alpine \
      -it \
      --privileged \
      -u root \
      -v make-alpine:/home/build/out \
      make-alpine:arm32v7 \
      make-alpine \
        --name alpine-rpi3 \
        --workdir /home/build/out \
        /usr/local/lib/make_alpine/config/{base_sys,rpi3.fw+kernel,alpine_user,net+ssh,location_se,docker}

### Copy image onto media

* Copy image from docker-container:
`docker cp make-alpine:/home/build/cache/${image_name} .`.
* Copy the raw image onto the SD-card with:
`dd if=${image_name} of=/dev/mmcblk0 bs=1M status=progress && sync`.

### Finally

* Resize the root partition and file system with `parted`, dependent on your
  needs.
* Set a root-password from user alpine with `sudo su` and `passwd`.
* Set a broadcast hostname in dhcp requests by configuring
  `/etc/network/interfaces`.
* Optional: Mount tmpfs over root filesystem to write-protect by adding
  `overlaytmpfs=yes` into `cmdline.txt`.

## References

* <https://gitlab.alpinelinux.org/alpine/aports/tree/master/scripts>
  builds run-from-ram and not sys-installations, i.e. you need to run
  `setup-alpine` on target to get a sys-installation.
* <https://github.com/alpinelinux/alpine-make-vm-image>
  is intended to build virtual machine disks only.
* <https://github.com/alpinelinux/alpine-chroot-install>
  not easily adapted to fit inside a multi-arch
  docker-container.
* <https://github.com/knoopx/alpine-raspberry-pi> and
  <https://github.com/hoshsadiq/alpine-raspberry-pi> seems to share the same
  goal as this project but is based on alpine-chroot-install above.
