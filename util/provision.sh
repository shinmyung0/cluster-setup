#! /bin/bash
if [ $# -lt 2 ]; then
  echo "Incorrect Number of Arguments:: (consul/nomad) (server/client) [root]"
  exit 1
else

  # Copy needed binaries
  sudo cp -f /vagrant/util/bin/nomad /usr/local/bin/
  sudo cp -f /vagrant/util/bin/consul /usr/local/bin/
  sudo cp -f /vagrant/util/bin/consul-template /usr/local/bin/



  TYPE="$1"
  FUNCTION="$2"
  IS_ROOT="$3"

  # Consul provisioning
  if [ "$TYPE" == "consul" ]; then

    if [ "$FUNCTION" == "server" ]; then

      if [ "$IS_ROOT" == "root" ]; then
        /vagrant/util/setup-consul.sh server root $4
      else
        /vagrant/util/setup-consul.sh server
      fi

    elif [ "$FUNCTION" == "client" ]; then
      /vagrant/util/setup-consul.sh client
    else
      echo "Invalid consul type: 'client' or 'server'"
      exit 1
    fi

  # Nomad provisioning
elif [ "$TYPE" == "nomad" ]; then

    if [ "$FUNCTION" == "server" ]; then

      if [ "$IS_ROOT" == "root" ]; then
        /vagrant/util/setup-nomad.sh server root $4
      else
        /vagrant/util/setup-nomad.sh server
      fi

    elif [ "$FUNCTION" == "client" ]; then
      /vagrant/util/setup-nomad.sh client
    else
      echo "Invalid nomad type: 'client' or 'server'"
      exit 1
    fi
  else
    echo "Uncognized type : $TYPE $FUNCTION"
  fi

fi

exit
