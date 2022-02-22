#!/bin/bash
docker stop consul_server1_contanier;docker rm consul_server1_contanier;
docker stop consul_server2_contanier;docker rm consul_server2_contanier;
docker stop consul_server3_contanier;docker rm consul_server3_contanier;
docker stop consul_client1_contanier;docker rm consul_client1_contanier;

docker pull consul:latest;

LOCATION_DIR="/Users/17tech/wwwroot/test/consul/";


rm -rf $LOCATION_DIR/data;
rm -rf $LOCATION_DIR/conf;

mkdir -p $LOCATION_DIR/data/server1;
mkdir -p $LOCATION_DIR/data/server2;
mkdir -p $LOCATION_DIR/data/server3;
mkdir -p $LOCATION_DIR/data/client1;
mkdir -p $LOCATION_DIR/conf/server1;
mkdir -p $LOCATION_DIR/conf/server2;
mkdir -p $LOCATION_DIR/conf/server3;
mkdir -p $LOCATION_DIR/conf/client1;

#启动consul_node_server1节点
docker run -d  -p 8510:8500 --restart=always -v $LOCATION_DIR/data/server1:/consul/data -v $LOCATION_DIR/conf/server1:/consul/config -e CONSUL_BIND_INTERFACE=eth0 --privileged=true --name=consul_server1_contanier consul:latest agent -server -bootstrap-expect=3 -ui -node=consul_node_server1  -client=0.0.0.0  -data-dir  /consul/data  -config-dir  /consul/config -datacenter=datacenter1

#获取consul_node_server1节点IP作为leader server节点
JOIN_IP="$(docker inspect -f '{{.NetworkSettings.IPAddress}}' consul_server1_contanier)";

#启动follower server节点
docker run -d -p 8520:8500 --restart=always -v $LOCATION_DIR/data/server2:/consul/data -v $LOCATION_DIR/conf/server2:/consul/config -e CONSUL_BIND_INTERFACE=eth0 --privileged=true --name=consul_server2_contanier consul:latest agent -server -ui -node=consul_node_server2 -client=0.0.0.0  -data-dir /consul/data -config-dir /consul/config -datacenter=datacenter1 -join=$JOIN_IP
docker run -d -p 8530:8500 --restart=always -v $LOCATION_DIR/data/server3:/consul/data -v $LOCATION_DIR/conf/server3:/consul/config -e CONSUL_BIND_INTERFACE=eth0 --privileged=true --name=consul_server3_contanier consul:latest agent -server -ui -node=consul_node_server3 -client=0.0.0.0  -data-dir /consul/data -config-dir /consul/config -datacenter=datacenter1 -join=$JOIN_IP


#启动client
docker run -d -p 8540:8500 --restart=always -v $LOCATION_DIR/conf/client1:/consul/config -e CONSUL_BIND_INTERFACE=eth0 --name=consul_client1_contanier consul:latest agent -node=consul_node_client1 -client=0.0.0.0 -datacenter=datacenter1 -config-dir /consul/config -join=$JOIN_IP
