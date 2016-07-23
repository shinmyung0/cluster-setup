#! /bin/bash
echo "Running Nginx container with Consul-template..."
/usr/bin/docker run -d --name nginx \
--volume /vagrant/templates/service.ctmpl:/templates/service.ctmpl \
--net=host \
shinmyung0/nginx-consultemplate
