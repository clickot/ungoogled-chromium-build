# ungoogled-chromium-build

Portable Linux build and packaging for [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium).
The code is mainly adapted from [ungoogled-chromium-portablelinux](https://github.com/ungoogled-software/ungoogled-chromium-portablelinux) repo.

## building
execute `docker-build.sh` script in the root dir. This will
* build a docker images based on debian bullseye with all needed node, llvm and distro packages to build chromium
* start the docker image, mounts the current dir and runs `build.sh` in it, which executes the actual build process.
>Note that the build takes about 6 hours (on my computer) and consumes about 15G of disk space

## packaging
After building, enter the `package` directory and excute `package.sh`. This will create a tar.xz and an AppImage file in the root dir. It takes about 2-3 minutes.
You may use the `prepare-publish.sh` script to create commits in the `ungoogled-chromium-binaries` fork for a pull request in the origin [ungoogled-chromium-binaries](https://github.com/ungoogled-software/ungoogled-chromium-binaries) repo.
