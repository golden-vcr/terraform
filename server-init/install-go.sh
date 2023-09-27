#!/usr/bin/env bash

GO_VERSION="1.21.1"
GO_INSTALL_DIR="/usr/local/go"
GO_TGZ_FILENAME="go$GO_VERSION.linux-amd64.tar.gz"
GO_TGZ_URL="https://go.dev/dl/$GO_TGZ_FILENAME"

HAS_REQUIRED_VERSION="0"
GO_VERSION_OUTPUT=$(go version)
if [ $? -eq 0 ]; then
    HAS_REQUIRED_VERSION=$(echo "$GO_VERSION_OUTPUT" | grep -cF "go version go$GO_VERSION")
fi

if [ "$HAS_REQUIRED_VERSION" == "1" ]; then
    echo "Go $GO_VERSION is already installed."
    exit
fi

echo "Installing Go $GO_VERSION to /usr/local/go..."
set -e
curl -LO "$GO_TGZ_URL"
rm -rf /usr/local/go
tar -C /usr/local -xzf "$GO_TGZ_FILENAME"
rm "$GO_TGZ_FILENAME"
export PATH=/usr/local/go/bin:$PATH

if [ $(grep -cF 'export PATH=/usr/local/go/bin:$PATH' /etc/bash.bashrc) == "0" ]; then
    echo "Adding /usr/local/go/bin to PATH in /etc/bash.bashrc..."
    echo -e 'export PATH=/usr/local/go/bin:$PATH\n' > ./tmpbashrc
    cat /etc/bash.bashrc >> ./tmpbashrc
    mv -f ./tmpbashrc /etc/bash.bashrc
fi

go version
