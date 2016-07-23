#! /bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>> Setting up Nomad $1"


if [ "$1" == "server" ]; then
  IS_SERVER=true
else
  IS_SERVER=false
fi

if [ "$2" == "root" ]; then
  echo "IS root server"
  IS_ROOT=true
  BOOTSTRAP_NUM=$3
else
  IS_ROOT=false
fi


MY_IP=$(ifconfig eth1 | grep "inet addr" | cut -d: -f2 | cut -d" " -f1)
NOMAD_DATA_DIR=~/nomad


# Kill any running nomad processes
PID=$(ps -ef | grep '[n]omad agent' | tr -s " " | cut -d" " -f2)
if [ "$PID" != "" ]; then
  echo "Cleaning up nomad process : $PID"
  sudo kill $PID
fi
sudo rm -rf $NOMAD_DATA_DIR

if [ $IS_SERVER == true ]; then



  if [ $IS_ROOT == true ]; then

    echo "Removing file"
    sudo rm -f /vagrant/util/nomad_root.ip

    # Initialize root server
    echo "Initialize the root server on : $MY_IP"
    nomad agent -server \
    -bootstrap-expect=$BOOTSTRAP_NUM \
    -bind=$MY_IP \
    -data-dir=$NOMAD_DATA_DIR > /dev/null &

    # Write the root server ip to a file in /vagrant
    echo "Writing root server ip to file : $MY_IP"
    echo $MY_IP > /vagrant/util/nomad_root.ip
    sudo chmod 666 /vagrant/util/nomad_root.ip

  else
    ROOT_SERVER_IP=$(cat /vagrant/util/nomad_root.ip)

    echo "Initialize a server on : $MY_IP, connecting to : $ROOT_SERVER_IP"
    nomad agent -server \
    -bind=$MY_IP \
    -data-dir=$NOMAD_DATA_DIR \
    -retry-join=$ROOT_SERVER_IP > /dev/null &


  fi
else

  # Set up a nomad client
  ROOT_SERVER_IP=$(cat /vagrant/util/nomad_root.ip)
  nomad agent -client \
  -servers=$ROOT_SERVER_IP:4647 \
  -bind=$MY_IP \
  -network-interface=eth1 \
  -data-dir=$NOMAD_DATA_DIR > /dev/null &



fi


# Check if NOMAD_ADDR is set as an environment variable
echo "Checking if NOMAD_ADDR is set properly..."
CHECK=$(cat /etc/bash.bashrc | grep "http://$MY_IP:4646")
if [ "$CHECK" == "" ]; then
    echo "Updating .bashrc file with proper env var"
    sudo echo "export NOMAD_ADDR=http://$MY_IP:4646" >> /etc/bash.bashrc
fi



exit
