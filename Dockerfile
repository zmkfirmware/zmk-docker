FROM debian:stable-20201117-slim AS common

CMD ["/bin/bash"]

ENV DEBIAN_FRONTEND=noninteractive

ARG REPOSITORY_URL=https://github.com/innovaker/zmk-docker
LABEL org.opencontainers.image.source ${REPOSITORY_URL}

ARG ZEPHYR_VERSION
ENV ZEPHYR_VERSION=${ZEPHYR_VERSION}
RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  ccache \
  cmake \
  file \
  gcc \
  gcc-multilib \
  git \
  gperf \
  make \
  ninja-build \
  python3 \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-base.txt \
  && apt-get remove -y --purge \
  python3-pip \
  python3-setuptools \
  python3-wheel \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------

FROM common AS dev-generic

RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  g++-multilib \
  libsdl2-dev \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  python3-tk \
  python3-wheel \
  wget \
  xz-utils \
  && pip3 install \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-build-test.txt \
  -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/v${ZEPHYR_VERSION}/scripts/requirements-run-test.txt \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=

#------------------------------------------------------------------------------

FROM common AS build

ARG ARCHITECTURE
ARG ZEPHYR_SDK_VERSION
ARG ZEPHYR_SDK_SETUP_FILENAME=zephyr-toolchain-${ARCHITECTURE}-${ZEPHYR_SDK_VERSION}-setup.run
ARG ZEPHYR_SDK_INSTALL_DIR=/opt/zephyr-sdk-${ZEPHYR_SDK_VERSION}
RUN \
  apt-get -y update \
  && apt-get -y install --no-install-recommends \
  bzip2 \
  wget \
  xz-utils \
  && wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZEPHYR_SDK_VERSION}/${ZEPHYR_SDK_SETUP_FILENAME}" \
  && sh ${ZEPHYR_SDK_SETUP_FILENAME} --quiet -- -d ${ZEPHYR_SDK_INSTALL_DIR} \
  && rm ${ZEPHYR_SDK_SETUP_FILENAME} \
  && apt-get remove -y --purge \
  bzip2 \
  wget \
  xz-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------------------------

FROM dev-generic AS dev

COPY --from=build ${ZEPHYR_SDK_INSTALL_DIR} ${ZEPHYR_SDK_INSTALL_DIR}