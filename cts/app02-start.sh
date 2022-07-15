#! /bin/bash
docker run -d --name=app02 -e CONSUL_BIND_INTERFACE=eth0 -e CONSUL_NODE_NAME=consul-node-02 -e CONSUL_LOCAL_CONFIG='{"service":{"id":"App-02","name":"App","tags":["app"],"port":80,"check":{"args":["curl","localhost"],"interval":"3s"}}}' cts-nginx:0.1