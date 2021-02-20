#!/bin/bash
vagrant up
PS3='Please enter your choice: '
options=("Monitor worker-1" "Monitor worker-2" "Monitor router" "Monitor switch" "Visualize information worker-1" "Visualize information worker-2" "Visualize information router" "Visualize information switch" "Visualize information bandwidth" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Monitor worker-1")
            echo "you chose choice $REPLY which is $opt"
            echo "Collecting information..."
            echo "press Ctrl+C when you want to stop the monitoring of the net and wait"
            VBoxManage metrics collect --period 4 --samples 1 worker-1 CPU/Loader/User,CPU/Load/Kernel,RAM/Usage/Used,Disk/Usage/Used,Net/Rate/Rx,Net/Rate/Tx,Guest/RAM/Usage/Total,Guest/RAM/Usage/Free | tee worker-1.txt
            ;;
        "Monitor worker-2")
            echo "you chose choice $REPLY which is $opt"
            echo "Collecting information..."
            echo "press Ctrl+C when you want to stop the monitoring of the net and wait"
            VBoxManage metrics collect --period 4 --samples 1 worker-2 CPU/Loader/User,CPU/Load/Kernel,RAM/Usage/Used,Disk/Usage/Used,Net/Rate/Rx,Net/Rate/Tx,Guest/RAM/Usage/Total,Guest/RAM/Usage/Free | tee worker-2.txt
            ;;
        "Monitor router")
            echo "you chose choice $REPLY which is $opt"
            echo "Collecting information..."
            echo "press Ctrl+C when you want to stop the monitoring of the net and wait"
            VBoxManage metrics collect --period 4 --samples 1 Router CPU/Loader/User,CPU/Load/Kernel,RAM/Usage/Used,Disk/Usage/Used,Net/Rate/Rx,Net/Rate/Tx,Guest/RAM/Usage/Total,Guest/RAM/Usage/Free | tee router.txt        
            ;;
        "Monitor switch") 
            echo "you chose choice $REPLY which is $opt"
            echo "Collecting information..."
            echo "press Ctrl+C when you want to stop the monitoring of the net and wait"
            VBoxManage metrics collect --period 4 --samples 1 Switch CPU/Loader/User,CPU/Load/Kernel,RAM/Usage/Used,Disk/Usage/Used,Net/Rate/Rx,Net/Rate/Tx,Guest/RAM/Usage/Total,Guest/RAM/Usage/Free | tee switch.txt
            ;;
        "Visualize information worker-1")
            echo "you chose choice $REPLY which is $opt"
            echo "Here it is what is written in worker-1.txt"
            cat worker-1.txt
            ;;
        "Visualize information worker-2")
            echo "you chose choice $REPLY which is $opt"
            echo "Here it is what is written in worker-2.txt"
            cat worker-2.txt
            ;;
        "Visualize information router")
            echo "you chose choice $REPLY which is $opt"
            echo "Here it is what is written in router.txt"
            cat router.txt
            ;;
        "Visualize information switch")
            echo "you chose choice $REPLY which is $opt"
            echo "Here it is what is written in switch.txt"
            cat switch.txt
            ;;
        "Visualize information bandwidth")
            echo "you chose choice $REPLY which is $opt"
            echo "From which device you want to measure it?"
            echo "Enter the number: worker-1 (1), worker-2 (2), switch (3), router (4)"
            echo "Instead if you want to exit digit exit"
read number

if test $number = "1"
    then
    echo "please wait until the program will place you inside worker-1."
    echo "Then enter the command:"
    echo "sudo tc qdisc show dev [name of the interface you want do display]"
    echo "You can select one of the ensuing interfaces:"
    echo "enp0s8"
    vagrant ssh host-a
else if test $number = "2"
    then
    echo "please wait until the program will place you inside worker-2"
    echo "Then enter the command:"
    echo "sudo tc qdisc show dev [name of the interface you want do display]"
    echo "You can select one of the ensuing interfaces:"
    echo "enp0s8"
    vagrant ssh host-b
else if test $number = "3"
    then
    echo "please wait until the program will place you inside the switch."
    echo "Then enter the command:"
    echo "sudo tc qdisc show dev [name of the interface you want do display]"
    echo "You can select one of the ensuing interfaces:"
    echo "enp0s8, enp0s9, enp0s10"
    vagrant ssh switch
else if test $number = "4"
    then
    echo "please wait until the program will place you inside the router."
    echo "Then enter the command:"
    echo "sudo tc qdisc show dev [name of the interface you want do display]"
    echo "You can select one of the ensuing interfaces:"
    echo "enp0s8.2, enp0s8.3"
    vagrant ssh router 
    else
        echo "Not a known interface"
        exit 1
    fi
fi
fi
fi       
            ;;
            "Quit")
            break
            ;;
        *) echo "exit $REPLY";;
    esac
done
