#! /bin/bash

echo ">>>>>>>>>>>>>>>>>>>>>>>>>> Setting up Consul $1"

if [ "$1" == "server" ]; then
  IS_SERVER=true
else
  IS_SERVER=false
fi


if [ "$2" == "root" ]; then
  echo "Setting up a root server"
  IS_ROOT=true
  BOOTSTRAP_NUM=$3

else
  IS_ROOT=false
fi


MY_IP=$(ifconfig eth1 | grep "inet addr" | cut -d: -f2 | cut -d" " -f1)
CONSUL_DATA_DIR=~/consul


# Kill any running consul processes
PID=$(ps -ef | grep '[c]onsul agent' | tr -s " " | cut -d" " -f2)
if [ "$PID" != "" ]; then
  echo "Cleaning up consul process : $PID"
  sudo kill $PID
fi

sudo rm -rf $CONSUL_DATA_DIR

if [ $IS_SERVER == true ]; then


  if [ $IS_ROOT == true ]; then

    echo "Removing file"
    sudo rm -f /vagrant/util/consul_root.ip

    # Initialize root server
    echo "Initialize the root server on : $MY_IP"
    consul agent -server -ui \
    -bootstrap-expect=$BOOTSTRAP_NUM \
    -bind=$MY_IP \
    -data-dir=$CONSUL_DATA_DIR \
    -client=0.0.0.0 > /dev/null &

    # Write the root server ip to a file in /vagrant
    echo "Writing root server ip to file : $MY_IP"
    echo $MY_IP > /vagrant/util/consul_root.ip
    sudo chmod 666 /vagrant/util/consul_root.ip

  else
    ROOT_SERVER_IP=$(cat /vagrant/util/consul_root.ip)

    echo "Initialize a server on : $MY_IP, connecting to : $ROOT_SERVER_IP"
    consul agent -server -ui \
    -bind=$MY_IP \
    -data-dir=$CONSUL_DATA_DIR \
    -retry-join=$ROOT_SERVER_IP \
    -client=0.0.0.0 > /dev/null &


  fi
else
  # Setup a client
  ROOT_SERVER_IP=$(cat /vagrant/util/consul_root.ip)

  consul agent -client=0.0.0.0 -ui \
  -retry-join=$ROOT_SERVER_IP \
  -bind=$MY_IP \
  -data-dir=$CONSUL_DATA_DIR > /dev/null &

fi


exit
