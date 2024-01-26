FROM ubuntu:focal-20231211 AS common

CMD ["/bin/bash"]

ENV DEBIAN_FRONTEND=noninteractive

ARG ZEPHYR_VERSION
ENV ZEPHYR_VERSION=${ZEPHYR_VERSION}
RUN \
  apt-get -y update \
  && if [ "$(uname -m)" = "x86_64" ]; then gcc_multilib="gcc-multilib"; else gcc_multilib=""; fi \
  && apt-get -y install --no-install-recommends \
  ccache \
  file \
  gcc \
  "${gcc_multilib}" \
  git \
  gperf \
  make \
  ninja-build \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  ssh \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-base.txt \
  && pip3 install cmake \
  && apt-get remove -y --purge \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------

FROM common AS dev-generic

ENV LC_ALL=C
ENV PAGER=less

RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  curl ca-certificates gnupg \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get -y update \
  && apt-get -y install --no-install-recommends \
  clang-format \
  gdb \
  gpg \
  gpg-agent \
  less \
  libpython3.8-dev \
  libsdl2-dev \
  locales \
  nano \
  nodejs \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-tk \
  python3-wheel \
  socat \
  tio \
  wget \
  xz-utils \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-build-test.txt \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-run-test.txt \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ARG ZEPHYR_SDK_VERSION
ENV ZEPHYR_SDK_VERSION=${ZEPHYR_SDK_VERSION}

ENV DEBIAN_FRONTEND=

#------------------------------------------------------------------------------

FROM common AS build

ARG ARCHITECTURE
ARG ZEPHYR_SDK_VERSION
ARG ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}
RUN \
  export minimal_sdk_file_name="zephyr-sdk-${ZEPHYR_SDK_VERSION}_linux-$(uname -m)_minimal" \
  && if [ "${ARCHITECTURE}" = "arm" ]; then arch_format="eabi"; else arch_format="elf"; fi \
  && if [ "${ARCHITECTURE#xtensa}" = "${ARCHITECTURE}" ]; then arch_sep="-"; else arch_sep="_"; fi \
  && apt-get -y update \
  && apt-get -y install --no-install-recommends \
  wget \
  xz-utils \
  && cd ${TMP} \ 
  && wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${minimal_sdk_file_name}.tar.xz" \
  && tar xvfJ ${minimal_sdk_file_name}.tar.xz \
  && mv zephyr-sdk-${ZEPHYR_SDK_VERSION} /opt/ \
  && rm ${minimal_sdk_file_name}.tar.xz \
  && cd /opt/zephyr-sdk-${ZEPHYR_SDK_VERSION} \
  && ./setup.sh -h -c -t ${ARCHITECTURE}${arch_sep}zephyr-${arch_format} \
  && cd \
  && apt-get remove -y --purge \
  wget \
  xz-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------

FROM dev-generic AS dev

COPY --from=build ${ZEPHYR_SDK_INSTALL_DIR} ${ZEPHYR_SDK_INSTALL_DIR}
