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

This is a simple example of a Network made up by a switch, a router and two hosts, worker-1 and worker-2.
As a consequence it is possible to identify two subnets:
- For the first one, which is between the router and worker-1, we used the address 192.168.0.0/23
- For the second one, which is between the router and worker-2, we used the address 192.168.2.0/23

# Ip configuration and VLAN
Then, we proceeded to create two VLANs: one meant for subnet-2, with Tag "2". The other one for subnet-3 with Tag "3". The choice of creating two VLANs was made in order to distinguish the network belonging to Host-A and the network belonging to Host-B.
| Device name       | Ip Address        | Network Interface   |  Subnet      |
| -------------     | -------------     | -------------       |------------- |
| Router-1          | 192.168.0.1       | enp0s8.2            |   2          |
| Host-A            | 192.168.0.2       | enp0s8              |   2          |
| Router-1          | 192.168.2.1       | enp0s8.3            |   3          |
| Host-B            | 192.168.2.2       | enp0s8              |   3          |

# Vagrant file

All Vagrant configuration is done in the file called Vagrantfile.
It contains the settings of each virtual machine.
Notes: the memory of worker-1 and worker-2 had to be increased to 512 with the command `vb.memory` due to the fact they have to be able to download a docker image inside themselves.

# Devices Configuration

## Switch

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine4.png)

The first three lines are provided in a template and have the purpose to install the commands for the configuration of the switch itself.
The second step is to create the bridge with the so called command `add-br`.
Then we have a command belonging to Netem, `sudo tc qdisc add dev [name of interface] root tbf rate [value] burst [value] latency [value]` in order to have a bandwidth limit network as it was requested. It is applied to all its four interfaces.
It is not a bidirectional instruction so it is necessary to insert it also in the other devices even if all the traffic of the net passes through the switch.
Finally the commands `sudo ip link set [name of the interface] up` are used to enable all the different interfaces.

## Router-1

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine5.png)

First of all it is necessary to enable the Kernel option for IP forwarding with the command `sudo sysctl -w net.ipv4.ip_forward=1`.
Then the other commands are fundamental in order to connect the router with the two hosts.
`sudo ip link add link enp0s8 name enp0s8.2 type vlan id 2` and `sudo ip link add link enp0s8 name enp0s8.2 type vlan id 3` add virtual links to the two subnets of the hosts.
`sudo ip addr add 192.168.0.1/23 dev enp0s8.2` and `sudo ip addr add 192.168.0.1/23 dev enp0s8.3` are meant to associate the IP addresses with the interfaces.
Afterwards we have a command belonging to Netem, `sudo tc qdisc add dev [name of interface] root tbf rate [value] burst [value] latency [value]` in order to have a bandwidth limit network as it was requested.
To conclude `sudo ip link set dev enp0s8 up` brings the interfaces up.

## Worker-1

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine6.png)

The commands are the same as the ones used in the router and in the switch: so we begin by giving a correct ip address to our interface.
Then we activate this interface.
Finally we connect worker-1 with the router thanks to the command `sudo ip route add [ip address] via [ip address]`.It means that if we want to reach the network 10.1.1.0/30 it is necessary to contact the gateway with ip 192.168.0.1 using the interface enp0s8.
Then we have a command belonging to Netem, `sudo tc qdisc add dev [name of interface] root tbf rate [value] burst [value] latency [value]` in order to have a bandwidth limit network as it was requested.
The commands which figure in the last lines are up to install a docker image in order to make more realistic our network and so they are not necessary for the creation of this host itself.

## Worker-2

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine7.png)

We start by giving a correct ip address to our interface.
Then we activate this interface.
After that we connect worker-2 with the router thanks to the command `sudo ip route add [ip address] via [ip address]`. It means that if we want to reach the netowrk 10.1.1.0/30 it is necessary to contact the gateway with ip 192.168.2.1 using the interface enp0s8.
Then we have a command belonging to Netem, `sudo tc qdisc add dev [name of interface] root tbf rate [value] burst [value] latency [value]` in order to have a bandwidth limit network as it was requested.
As for worker-1 the commands which figure in the last lines are up to install a docker image in order to make more realistic our network and so they are not necessary for the creation of this host itself.

# So now we have the network, how to go on?

First of all it is necessary to press the command `bash test.sh` in order to open the bash men, "test.sh".
This passage may request a while because the first step it has to do is to create the network itself by means of `vagrant up`.
After that you will be able to see all the possible options. So read them carefully.
You may want to monitor one of the devices and print the corrispondent information in a file.txt, or maybe you just prefer to open and read one of these files.txt you have already generated.
All you need to do is digit the appropriate number and follow the instructions provided.
It is also possible for you to check if the band is actually limited, by writing the number associated to whichever device you want and then by choosing one of the suggested interfaces.
Trying these options you will find two important commands. They are the one that allows you to monitor the previously choosen device and the one to check the limits of the bandwidth.
`VBoxManage metrics collect --period [time] --samples 1 worker-1 CPU/Loader/User,CPU/Load/Kernel,RAM/Usage/Used,Disk/Usage/Used,Net/Rate/Rx,Net/Rate/Tx,Guest/RAM/Usage/Total,Guest/RAM/Usage/Free | tee [name of the device].txt`: this command collects information about the net and both print it on the screen and inside a file .txt.
It is also possible to monitor other parameters, in fact the complete command is the following: `VBoxManage metrics collect --period [time] --samples 1 serverName CPU/Load/User,CPU/Load/Kernel,RAM/Usage/Used,Disk/Usage/Used,Net/Rate/Rx,Net/Rate/Tx,Guest/CPU/Load/User,Guest/CPU/Load/Kernel,Guest/CPU/Load/Idle,Guest/RAM/Usage/Total,Guest/RAM/Usage/Free,Guest/RAM/Usage/Balloon,Guest/RAM/Usage/Shared,Guest/RAM/Usage/Cache,Guest/Pagefile/Usage/Total`
Of course both the values of the net-rate transmitted and received are null as there are no packets travelling in the net itself unless we create a ping command. (So if you want to measure the net-rate of a device 1 from a device 2 , you have to enter in the device 2 (ssh) and digit `ping [address of the other device 1]` and let it work.
In another  terminal you reinsert the previous instruction with the name of the device 1).
`sudo tc qdisc show dev [name of the interface you want do display]` : it is used to verify the limit of the bandwidth.

![demo](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Bash.gif)

## About test.sh

We have written here all the commands in order to create an interactive menu. So we have employed some use cases in order to provide all the different alternatives:
- The first four options are about the possibility to launch the command to monitor the behaviour of the net and save this information collected in a file.txt.
- The second four options allow us to open and display the files.txt we have created by using the command `cut [name of the file].txt`.
- The last one shows that the bandwidth is actually limited. The passages in order to do so are:
- choose a device
- enter the device (`vagrant ssh [name of the device`])
- write the command suggested in the terminal
The commands within the nine options are automated and when they are not is because they are interactive.
The tenth option let us exite from this menu.

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine9.png)

![alt text here](https://github.com/calorechiara/Monitoring-Virtualized-Networks/blob/main/other/Immagine1.png)

## Team members
This project has been realised by Miotto Sara (matriculation number: 202440), Cesaro Pasquale Alan (matriculation number: 202182) and Calore Chiara (matriculation number: 202404) 

