# Assignment

- To deploy a network of virtual machines/containers hosted on one or more PCs
- The connections between twoVMs/containers should be bandwidth-limited (see Netem later)
- Networking should be based on OpenVSwitch
- To analyze the state of the system by collecting information about: VMs/containers resource utilization (CPU/memory/etc.) and link usage

## Suggested packages:

- Netem https://alexei-led.github.io/post/pumba_docker_netem/
- Docker/VM hypervisor monitoring APIs

# Network Schema

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/007055b2-0ff4-4243-99a8-18b82abe163a.jpg)

This is a simple example of a Network made up by a switch, a router and two hosts, worker-1 and worker-2. As a consequence it is possible to identify two subnets:
- For the first one, which is between the router and worker-1, we used the address 192.168.0.0/23
- For the second one, which is between the router and worker-2, we used the address 192.168.2.0/23

# Vagrant file

All Vagrant configuration is done in the file called Vagrantfile. It contains the settings of each virtual machine.
Notes: the memory of worker-1 and worker-2 had to be increased to 512 with the command `vb.memory` due to the fact they have to be able to download a docker image inside themselves.


# Devices Configuration

## Switch

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine4.png)

The first three lines are provided in a template and have the purpose to install some useful commands for the configuration of the switch itself (it is based on OpenVSwitch as it was requested).
The second step is to create a bridge with the so called command `add-br`.
After that, `sudo ovs-vsctl add-port switch [name of the interface]`generates the ports to communicate with the other devices.
Then we have a command belonging to Netem, `sudo tc qdisc add dev [name of interface] root tbf rate [value] burst [value] latency [value]` in order to have a bandwidth limit network. It is applied to all its four interfaces.
Finally the commands `sudo ip link set [name of the interface] up` are used to enable all the different interfaces.

## Router-1

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine5.png)

First of all it is necessary to enable the Kernel option for IP forwarding with the command `sudo sysctl -w net.ipv4.ip_forward=1`.
Then the other commands are fundamental in order to connect the router with the two hosts.
`sudo ip link add link enp0s8 name enp0s8.2 type vlan id 2` and `sudo ip link add link enp0s8 name enp0s8.2 type vlan id 3` add virtual links to the two subnets of the hosts.
`sudo ip addr add 192.168.0.1/23 dev enp0s8.2` and `sudo ip addr add 192.168.0.1/23 dev enp0s8.3` are meant to associate the IP addresses with the interfaces.
Afterwards we have a command belonging to Netem, `sudo tc qdisc add dev [name of interface] root tbf rate [value] burst [value] latency [value]` in order to have a bandwidth limit network as it was requested.
To conclude `sudo ip link set dev enp0s8 up` brings the interface up.
The command `iperf -s &` is written in order to emulate the traffic within the net. The letter s means the router is actully the server of the net. The symbol "&" allows the execution of this command in background.

## Worker-1

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine6.png)

The commands are the same as the ones used in the router and in the switch: so we begin by giving a correct ip address to our interface.
Then we activate this interface.
Finally we connect worker-1 with the router thanks to the command `sudo ip route add [ip address] via [ip address]`. It means that if we want to reach the network 10.1.1.0/30 it is necessary to contact the gateway with ip 192.168.0.1 using the interface enp0s8.
Then we have a command belonging to Netem, `sudo tc qdisc add dev [name of interface] root tbf rate [value] burst [value] latency [value]` in order to have a bandwidth limit network as it was requested.
The commands which figure in the last lines are up to install a docker image in order to make more realistic our network and so they are not necessary for the creation of this host itself.
`iperf -c & [ip address server]` is written in order to emulate the traffic within the net. The letter c means worker-1 is the client of the net. The symbol "&" allows the execution of this command in background.

## Worker-2

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine7.png)

We start by giving a correct ip address to our interface.
Then we activate this interface.
Finally we connect worker-2 with the router thanks to the command `sudo ip route add [ip address] via [ip address]`.
Then we have a command belonging to Netem, `sudo tc qdisc add dev [name of interface] root tbf rate [value] burst [value] latency [value]` in order to have a bandwidth limit network as it was requested.
As for worker-1 the commands which figure in the last lines are up to install a docker image in order to make more realistic our network and so they are not necessary for the creation of this host itself.
The command `iperf -c [ip address server] &` is written in order to emulate the traffic within the net. The letter c means worker-2 is the client of the net. The symbol "&" allows the execution of this command in background.

# So now we have the network, how to go on?

First of all it is necessary to press the command `vagrant up` in order to generate the bandwidth limited virtual network you have previously configured in the Vagrantfile and in the other files.sh.
This passage may request a while.
Once it is ready, write in your terminal `bash test.sh`.
This command is udes to open a file.sh and as a consequence you will see another window about to open.
This is the bash menu with all the possible options.
So read them carefully.
You may want to monitor one of the devices and print the related information in a file.txt, or maybe you just prefer to open and to read one of these files.txt you have already generated.
All you need to do is digit the appropriate number and follow the instructions provided.
It is also possible for you to check if the band is actually limited by entering the number associated to whichever device you want and then by choosing one of the suggested interfaces.
Trying these options you will find two important commands.
They are the one that allows you to monitor the previously choosen device and the one to check the limits of the bandwidth.
`VBoxManage metrics collect --period 10 --samples 1 worker-1 CPU/Loader/User,CPU/Load/Kernel,RAM/Usage/Used,Disk/Usage/Used,Net/Rate/Rx,Net/Rate/Tx,Guest/RAM/Usage/Total,Guest/RAM/Usage/Free | tee [name of the device].txt`: this command collects information about the net and both print it on the screen and inside a file .txt.
`sudo tc qdisc show dev [name of the interface you want do display]` : it is used to verify the limit of the bandwidth.

![demo](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Bash.gif)

## About test.sh

We have written in this file all the necessary commands to create an interactive menu.
So we have employed some use cases in order to provide all the different alternatives.
The first four options are about the possibility to launch the command so as to monitor the behaviour of the net and to save the information collected in a proper file.txt.
The second four options allow us to open and display the files.txt we have created by using the command `cut [name of the file].txt`.
Finally the last one show the the bandwidth is actually limited. The passages in order to do so are:
- choose a device
- enter the device (`vagrant ssh [name of the device`])
- write the command suggested in the terminal
The commands within the nine options are automated and when they are not is because they are interactive.
The tenth option let us exite from this menu whenever we want to.

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine1.png)

## Team members
This project has been realised by Miotto Sara (matriculation number: 202440), Cesaro Pasquale Alan (matriculation number: 202182) and Calore Chiara (matriculation number: 202404) 


