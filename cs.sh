#!/bin/bash
set -e

echo Update package lists and install required packages
sudo apt-get update
sudo apt-get install -y python3 git virtualenv libmpfr-dev libssl-dev libmpc-dev libffi-dev build-essential python3-dev python3-pip python3.11-venv
echo Create a non-root user for running Cowrie
sudo adduser --disabled-password cowrie

echo Switch to the cowrie user and perform subsequent actions as that user
sudo -u cowrie bash << 'EOF'

cd ~

echo Clone the Cowrie repository
git clone https://github.com/micheloosterhof/cowrie.git

echo Navigate to the Cowrie directory
cd cowrie

echo Create a virtual environment and activate it
python3 -m venv cowrie-env
source cowrie-env/bin/activate

echo Upgrade pip and install required Python packages
pip install --upgrade pip
pip install -r requirements.txt

echo Generate SSH keys in the data directory
cd var/lib/cowrie
ssh-keygen -t dsa -b 1024 -f ssh_host_dsa_key
cd ..

echo Set the PYTHONPATH
export PYTHONPATH=/home/cowrie/cowrie

echo Copy the configuration file
cd ~/cowrie/etc
cp cowrie.cfg.dist cowrie.cfg

echo Update the hostname and listen_port in the configuration file
sed -i "s/hostname =.*/hostname = $(hostname)/" cowrie.cfg
sed -i "s/2222*/22/" cowrie.cfg

echo Enable AUTHBIND in the start.sh script
# to be removed sed -i 's/AUTHBIND_ENABLED=no/AUTHBIND_ENABLED=yes/' start.sh

EOF

echo Install authbind and configure it for port 22
sudo apt-get install -y authbind
sudo touch /etc/authbind/byport/22
sudo chown cowrie /etc/authbind/byport/22
sudo chmod 777 /etc/authbind/byport/22


#cd /home/cowrie/cowrie

#source cowrie-env/bin/activate 
#bin/createfs -l / -d 3 -o ./share/cowrie/tsu.pickle

#su cowrie << 'EOF'
#cd /home/cowrie/cowrie
#sed -i "s/fs.pickle/tsu.pickle/g"  ./etc/cowrie.cfg
#EOF
