ARG GOCD_VERSION
FROM gocd/gocd-agent-ubuntu-18.04:$GOCD_VERSION AS base

USER root

# CLI: Chef InSpec
ARG INSPEC_VERSION=4.18.51

RUN apt update && \
    apt-get install wget && \
    wget -qO- https://packages.chef.io/files/stable/inspec/${INSPEC_VERSION}/ubuntu/18.04/inspec_${INSPEC_VERSION}-1_amd64.deb > inspec.deb && \
    dpkg -i inspec.deb

# CLI: Terraform
FROM base AS terraform

ARG TERRAFORM_VERSION=0.12.18

RUN wget -qO- https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip > terraform.zip && \
    unzip -d /bin terraform.zip

# FINAL
FROM BASE

COPY --from=terraform /bin/terraform /bin

USER go

