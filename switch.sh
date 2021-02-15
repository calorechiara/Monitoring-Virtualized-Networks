export DEBIAN_FRONTEND=noninteractive
#Startup commands for switch go here
apt-get update
apt-get install -y tcpdump
apt-get install -y openvswitch-common openvswitch-switch apt-transport-https ca-certificates curl software-properties-common
#Switch ports config
sudo ovs-vsctl add-br switch
sudo ovs-vsctl add-port switch enp0s8
sudo ovs-vsctl add-port switch enp0s9 tag="2"
sudo ovs-vsctl add-port switch enp0s10 tag="3"
sudo apt install iperf
#sudo tc qdisc add dev enp0s3 root tbf rate 1mbit burst 32kbit latency 400ms
#sudo tc qdisc add dev enp0s8 root tbf rate 1mbit burst 32kbit latency 400ms
#sudo tc qdisc add dev enp0s9 root tbf rate 1mbit burst 32kbit latency 400ms
#sudo tc qdisc add dev enp0s10 root tbf rate 1mbit burst 32kbit latency 400ms
#Setting up links
sudo ip link set dev enp0s8 up
sudo ip link set dev enp0s9 up
sudo ip link set dev enp0s10 up
