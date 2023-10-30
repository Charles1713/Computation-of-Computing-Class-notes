#!/bin/bash
sudo su cowrie << 'EOF'
cd ~/cowrie/
source cowrie-env/bin/activate
echo `pwd`
echo starting hp
cd bin
./cowrie start
#./start.sh
EOF
