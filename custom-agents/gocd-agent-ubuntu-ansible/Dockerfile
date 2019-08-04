ARG GOCD_VERSION
FROM gocd/gocd-agent-ubuntu-18.04:$GOCD_VERSION

USER root

RUN curl https://bootstrap.pypa.io/get-pip.py -o /godata/get-pip.py && \
    python /godata/get-pip.py && \
    pip install ansible

USER go

