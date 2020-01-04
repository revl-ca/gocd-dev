ARG GOCD_VERSION
FROM gocd/gocd-agent-ubuntu-18.04:$GOCD_VERSION AS base

USER root

# CLI: Chef InSpec
ARG INSPEC_VERSION=4.18.51

RUN apt update && \
    apt-get install wget && \
    wget -qO- https://packages.chef.io/files/stable/inspec/${INSPEC_VERSION}/ubuntu/18.04/inspec_${INSPEC_VERSION}-1_amd64.deb > inspec.deb && \
    dpkg -i inspec.deb

# CLI: Packer
FROM base AS packer

ARG PACKER_VERSION=1.5.1

RUN wget -qO- https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip > packer.zip && \
    unzip -d /bin packer.zip

# FINAL
FROM BASE

COPY --from=packer /bin/packer /bin

USER go

