#!/bin/bash

~/Documents/Clarusway/Auto_Public_Ip_Pull/Auto_Public_Ip_Pull.sh | tee /dev/tty | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | cat | xargs -I {} sed -i "" -E "/^Host Turtle$/,/^Host / s/HostName .*/HostName {}/" ~/.ssh/config
