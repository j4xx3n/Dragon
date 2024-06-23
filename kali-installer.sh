#!/bin/bash

sudo apt update
sudo apt install golang-go -y
go install github.com/tomnomnom/gf@latest
git clone https://github.com/NitinYadav00/gf-patterns.git
sudo cp ~/go/bin/gf /usr/bin/
mkdir -p ~/.gf
cd gf-patterns/
cp *.json ~/.gf
cd ..
sudo apt install nuclei
go install github.com/hahwul/dalfox/v2@latest
sudo cp ~/go/bin/dalfox /usr/bin/
