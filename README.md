Lightweight Docker images for [ZMK][zmk].

### Platforms

#### Tested

- `arm`

#### Not Tested

- `arc`
- `arm64`
- `mips`
- `nios2`
- `riscv64`
- `sparc`
- `x86_64`
- `xtensa_intel_apl_adsp`
- `xtensa_intel_bdw_adsp`
- `xtensa_intel_byt_adsp`
- `xtensa_intel_s1000`
- `xtensa_nxp_imx8m_adsp`
- `xtensa_nxp_imx_adsp`
- `xtensa_sample_controller`

### Images

#### Build arguments

The building of the image requires the following build arguments:

- `ZEPHYR_VERSION`: version of [Zephyr][zephyr] to install (e.g. `4.1.0`)
- `ARCHITECTURE`: target architecture (e.g. `arm`, `x86_64`, etc.)
- `ZEPHYR_SDK_VERSION`: version of [Zephyr SDK][Zephyr SDK] to install (e.g. `0.17.4`)

Example:

```shell
docker build \
    --build-arg ZEPHYR_VERSION=4.1.0 \
    --build-arg ARCHITECTURE=x86_64 \
    --build-arg ZEPHYR_SDK_VERSION=0.17.4 \
    -t zmkfirmware/zmk-docker .
```

#### build

For _building_ [ZMK][zmk] firmware with CI.

- FROM: **[ubuntu][ubuntu]**
- Includes:
  - essential [Zephyr][zephyr] dependencies (`apt-get`)
    - non-build dependencies are _not_ included. e.g. `pip3`, UI packages, etc.
  - base [Zephyr][zephyr] Python requirements
  - platform's [Zephyr][zephyr] toolchain

#### dev

For _developing_ [ZMK][zmk] (firmware and documentation).

- FROM: **build**
- Includes:
  - remaining [Zephyr][zephyr] dependencies (`apt-get`)
  - build and test [Zephyr][zephyr] Python requirements
  - other useful development packages

[ubuntu]: https://hub.docker.com/_/ubuntu "Ubuntu"
[zephyr]: https://github.com/zephyrproject-rtos/zephyr "Zephyr"
[zmk]: https://github.com/zmkfirmware/zmk "ZMK"
[zephyr sdk]: https://github.com/zephyrproject-rtos/sdk-ng/tags "Zephyr SDK"
