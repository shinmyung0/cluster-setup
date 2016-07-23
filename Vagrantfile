# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "cargomedia/ubuntu-1504-default"

  # Fix random bug with 'std not a tty'
  config.vm.provision "fix-no-tty", type: "shell" do |s|
    s.privileged = false
    s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
  end



  # Provision root server
  config.vm.define "root-server" do |root|
    root.vm.network "private_network", type: "dhcp"
    root.vm.hostname = "root-server"

    # number after root is the -bootstrap-expect num passed to consul and nomad
    # this equals the number of followers
    root.vm.provision "shell", inline: "/vagrant/util/provision.sh consul server root 1"
    root.vm.provision "shell", inline: "/vagrant/util/provision.sh nomad server root 1"

    root.vm.provider "virtualbox" do |v|
      v.memory = 256
      v.cpus = 1
    end
  end


  # Provision follower servers
  # TODO Figure out a way to reliably delete state in the follower servers
  # (1..2).each do |d|
  #   config.vm.define "follower#{d}" do |follower|
  #     follower.vm.network "private_network", type: "dhcp"
  #     follower.vm.hostname = "follower#{d}"
  #     follower.vm.provision "shell", inline: "/vagrant/util/provision.sh consul server"
  #     follower.vm.provision "shell", inline: "/vagrant/util/provision.sh nomad server"
  #
  #     follower.vm.provider "virtualbox" do |v|
  #       v.memory = 256
  #       v.cpus = 1
  #     end
  #   end
  # end


  # Provision load balancer server
  config.vm.define "lb-server" do |lb|
    lb.vm.network "private_network", type: "dhcp"
    lb.vm.hostname = "lb-server"

    # This consul client will listen in on the consul cluster
    # Responsible for syncing with the nginx consultemplate process
    lb.vm.provision "shell", inline: "/vagrant/util/provision.sh consul client"


    # load docker images locally
    lb.vm.provision "docker"
    lb.vm.provision "shell", inline: "sudo sh -c 'docker rm -f $(docker ps -aq) ; true'"
    lb.vm.provision "shell", inline: "docker pull shinmyung0/nginx-consultemplate"
    lb.vm.provision "shell", inline: "/vagrant/util/run_nginx.sh"



    lb.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
  end



  # Provision client nodes
  (1..3).each do |d|
    config.vm.define "client#{d}" do |client|
      client.vm.network "private_network", type: "dhcp"
      client.vm.hostname = "client#{d}"
      client.vm.provision "docker"
      client.vm.provision "shell", inline: "sudo sh -c 'docker rm -f $(docker ps -aq) ; true'"

      # Load local images
      # client.vm.provision "shell", inline: "docker load -i /vagrant/images/fib-app.tar"
      # client.vm.provision "shell", inline: "docker load -i /vagrant/images/redis.tar"
      # client.vm.provision "shell", inline: "docker load -i /vagrant/images/cadvisor.tar"

      # Load local images
      client.vm.provision "shell", inline: "docker pull shinmyung0/fib-app"
      client.vm.provision "shell", inline: "docker pull redis"

      client.vm.provision "shell", inline: "/vagrant/util/provision.sh consul client"
      client.vm.provision "shell", inline: "/vagrant/util/provision.sh nomad client"



      # Provision Nginx and cAdvisor
      client.vm.provision "shell", inline: "/vagrant/util/run_cadvisor.sh"
      #client.vm.provision "shell", inline: "/vagrant/util/run_nginx.sh"

      client.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus = 1
      end
    end
  end







end
