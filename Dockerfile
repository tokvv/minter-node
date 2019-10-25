FROM ubuntu:19.04

ENV MINTERHOME /minter
ARG BINARY=minter
ARG USERNAME=minteruser

RUN apt update && \
    apt install -y curl jq bash unzip build-essential libsnappy-dev && \
    addgroup $USERNAME && \
    useradd -md "$MINTERHOME" -g $USERNAME $USERNAME

RUN curl -OL https://github.com/google/leveldb/archive/v1.20.tar.gz && \
    tar -zxvf v1.20.tar.gz && \
    cd leveldb-1.20 && \
    make && \
    cp -r out-static/lib* out-shared/lib* /usr/local/lib/ && \
    cd include/ && \
    cp -r leveldb /usr/local/include/ && \
    ldconfig && \
    rm -f v1.20.tar.gz

ARG VERSION

WORKDIR $MINTERHOME

RUN export DOWNLOAD_URL="https://github.com/MinterTeam/minter-go-node/releases/download/v${VERSION}/minter_$(echo ${VERSION} | sed -E 's/[a-z\-]+//')_linux_amd64.zip" && \
    echo "DOWNLOADING: $DOWNLOAD_URL" && \
    curl -L $DOWNLOAD_URL -o minter.zip && \
    unzip minter.zip && \
    rm -f minter.zip && \
    mv $BINARY /usr/bin/

USER $USERNAME

# api port
EXPOSE 8841 46658

ENTRYPOINT ["/usr/bin/minter"]
STOPSIGNAL SIGTERM
