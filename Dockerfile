#FROM debian:stable-slim
FROM mcr.microsoft.com/dotnet/sdk:8.0-noble

ARG BUILD_DATE
ARG COMMIT_SHA

# Azure DevOps Agent support adapted from https://github.com/tdevere/DevOpsAgentPoolLinux

# https://github.com/microsoft/azure-pipelines-agent/releases
ARG AGENT_VERSION=4.268.0

ENV AGENT_VERSION=${AGENT_VERSION} \
    JAVA_HOME=/usr/lib/jvm/default-java \
    JAVA_HOME_11_X64=/usr/lib/jvm/default-java \
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
  curl tar git ca-certificates docker.io default-jdk icu-devtools libicu74 libicu4j-java libicu-dev maven \
  sudo \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir /build
WORKDIR /build

RUN curl -LsS \
      https://download.agent.dev.azure.com/agent/${AGENT_VERSION}/vsts-agent-linux-x64-${AGENT_VERSION}.tar.gz \
    | tar -xz --no-same-owner

# The current version of the agent supports up to libicu74.
# debian 13 comes with libicu76.
# debian 12 comes with libicu72.
# ubuntu noble comes with libicu74
#RUN sed -i 's/libicu74/libicu76/g' /build/bin/installdependencies.sh

RUN /build/bin/installdependencies.sh

RUN useradd --create-home agent \
    && mkdir -p /build/_work /build/_tool \
    && usermod -aG docker agent \
    && usermod -aG sudo agent \
    && chown -R agent:agent /build \
    && mkdir -p /usr/local/share/ca-certificates/custom-ca \
    && chown -R agent:agent /usr/local/share/ca-certificates/custom-ca

RUN systemctl enable docker

RUN echo "Cmnd_Alias UTILS = /usr/sbin/update-ca-certificates, /usr/bin/systemctl" >> /etc/sudoers \
    && echo "%sudo ALL=NOPASSWD: UTILS" >> /etc/sudoers

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