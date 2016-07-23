
# Nomad + Consul Cluster Demo

1. Stack
  - Vagrant : VM setup
  - Nomad : scheduling
  - Consul : service discovery
  - Nginx + Consul Template : routing and proxy
  - [cAdvisor](http://github.com/google/cadvisor) : container/host monitoring

2. Cluster Setup
  - 1 root server with Consul/Nomad servers
  - 1 frontend Load Balancer with Nginx + Consul-template
  - 3 client servers with Consul/Nomad clients

I set this up to create a local testing environment to build a [autoscaler](http://github.com/shinmyung0/autoscaler) based on these technologies.


# Installing & Running

1. Run `vagrant up` to setup the cluster

2. Run `./update_host.sh` to add entries to host file (This only works on Mac OS X).
   This will setup the servers under the following hostnames.

  - root-server : root.server.demo
  - lb-server : frontend.lb.demo
  - client1 : client1.demo
  - client2 : client2.demo
  - client3 : client3.demo

3. At this point you now have a running cluster. Check `vagrant status` to verify all machines are running.
   To schedule a job:

  - From the project root directory, `vagrant ssh root-server` then `nomad run /vagrant/jobs/fib.nomad`
  to run a simple fibonacci job defined in `jobs/fib.nomad`.

  - From the browser, navigating to http://frontend.lb.demo:8500/ shows you the consul webUI

  - Currently there is only a single frontend LB with consul-template file for only the `fib` job located in `templates/service.ctmpl`.
    This LB handles all incoming requests and can route to any of the containers located on the client nodes because it queries a local
    consul client instance which is syncing with the server and all the clients.

  - At cluster setup, this template file is loaded into the `nginx` container running on the `lb-server`


4. If you run the `fib.nomad` job, you can verify the state of the job by
   running `nomad status fib` from the `root-server` or any of the clients.
   http://frontend.lb.demo/fib will go through the load balancer and into one of the fib containers.

5. You can also get a view of the cAdvisor webUI by navigating to any of the `client{1,2,3}.demo` servers on port 8080.
   (ie. http://client1.demo:8080/)

# Todo

1. Setup follower servers to simulate HA setup with Nomad and Consul (Can't do currently because of vagrant provisioning problems)
2. Setup a more generic consul-template to detect any type of service (not sure if this is possible, if not think about deployment methods)
3. Setup a system of backend LBs inside each client VM and map local containers to private network
4. Setup frontend LB to route to backend LBs
5. Incorporate [Terraform](https://www.terraform.io/) to simulate infrastructure scaling.


# References
- [nomad-intro](https://github.com/dontrebootme/nomad-intro) : Repository for SysAdvent article ["Introduction to Nomad"](http://sysadvent.blogspot.com/2015/12/day-12-introduction-to-nomad.html)
