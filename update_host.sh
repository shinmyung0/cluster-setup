#! /bin/bash


echo ">>>>>>>>>> Clearing any previous host entries"
sudo ./util/bin/hostess_osx64 del root.server.demo
sudo ./util/bin/hostess_osx64 del frontend.lb.demo
sudo ./util/bin/hostess_osx64 del client1.demo
sudo ./util/bin/hostess_osx64 del client2.demo
sudo ./util/bin/hostess_osx64 del client3.demo



# Grab all the ips
echo ">>>>>>>>>> Connecting to VMS and grabbing ip"
# Need to strip carriage return from vagrant ssh result
ROOT_SERVER_IP=$(vagrant ssh -c "ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1" root-server)
ROOT_SERVER_IP=$(echo $ROOT_SERVER_IP | tr -d '\r')
echo "Got IP : $ROOT_SERVER_IP"
LB_IP=$(vagrant ssh -c "ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1" lb-server)
LB_IP=$(echo $LB_IP | tr -d '\r')
echo "Got IP : $LB_IP"
CLIENT1_IP=$(vagrant ssh -c "ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1" client1)
CLIENT1_IP=$(echo $CLIENT1_IP | tr -d '\r')
echo "Got IP : $CLIENT1_IP"
CLIENT2_IP=$(vagrant ssh -c "ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1" client2)
CLIENT2_IP=$(echo $CLIENT2_IP | tr -d '\r')
echo "Got IP : $CLIENT2_IP"
CLIENT3_IP=$(vagrant ssh -c "ifconfig eth1 | grep 'inet addr' | cut -d: -f2 | cut -d' ' -f1" client3)
CLIENT3_IP=$(echo $CLIENT3_IP | tr -d '\r')
echo "Got IP : $CLIENT3_IP"


echo ">>>>>>>>>> Adding host entries for vms"
sudo ./util/bin/hostess_osx64 add root.server.demo $ROOT_SERVER_IP
echo "> root.server.demo -> $ROOT_SERVER_IP"
sudo ./util/bin/hostess_osx64 add frontend.lb.demo "$LB_IP"
echo "> frontend.lb.demo -> $LB_IP"
sudo ./util/bin/hostess_osx64 add client1.demo "$CLIENT1_IP"
echo "> client1.demo -> $CLIENT1_IP"
sudo ./util/bin/hostess_osx64 add client2.demo "$CLIENT2_IP"
echo "> client2.demo -> $CLIENT2_IP"
sudo ./util/bin/hostess_osx64 add client3.demo "$CLIENT3_IP"
echo "> client3.demo -> $CLIENT3_IP"
