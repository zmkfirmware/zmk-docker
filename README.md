Lightweight Docker images for [ZMK][zmk].

### Platforms

- `arm`

### Images

#### build

For _building_ [ZMK][zmk] firmware with CI.

- FROM: **[debian][debian]:stable-slim**
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

[debian]: https://hub.docker.com/_/debian "Debian"
[zephyr]: https://github.com/zephyrproject-rtos/zephyr "Zephyr"
[zmk]: https://github.com/zmkfirmware/zmk "ZMK"
