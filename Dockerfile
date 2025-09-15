FROM debian:stable-slim

ARG BUILD_DATE
ARG COMMIT_SHA

# Azure DevOps Agent support adapted from https://github.com/tdevere/DevOpsAgentPoolLinux

ARG AGENT_VERSION=4.255.0
ENV AGENT_VERSION=${AGENT_VERSION} \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
    JAVA_HOME_11_X64=/usr/lib/jvm/java-11-openjdk-amd64 \
    MAVEN_HOME=/usr/share/maven \
    M2_HOME=/usr/share/maven \
    PATH=${PATH}:${MAVEN_HOME}/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  devscripts \
  equivs \
  rsync \
  locales \
  wget gcc build-essential fakeroot git tar grep sed libncurses5-dev \
  libssl-dev libelf-dev bison flex time \
  dh-make nasm yasm \
  curl tar git ca-certificates docker.io openjdk-11-jdk-headless maven \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /build
WORKDIR /build

RUN curl -LsS \
      https://download.agent.dev.azure.com/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
    | tar -xz --no-same-owner

RUN /build/bin/installdependencies.sh

RUN useradd --create-home agent \
    && mkdir -p /build/_work /build/_tool \
    && usermod -aG docker agent \
    && chown -R agent:agent /build

COPY ./*.sh /build/
RUN chmod +x /build/*.sh \
    && chown agent:agent /build/*.sh

USER agent

ENTRYPOINT ["/build/entrypoint.sh"]

# https://github.com/opencontainers/image-spec/blob/master/spec.md
LABEL org.opencontainers.image.title='docker-deb-build' \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.description='Generic debian image to build deb packages' \
      org.opencontainers.image.documentation='https://github.com/jesusdf/docker-deb-build/blob/master/README.md' \
      org.opencontainers.image.version='1.0' \
      org.opencontainers.image.source='https://github.com/jesusdf/docker-deb-build' \
      org.opencontainers.image.revision="${COMMIT_SHA}"