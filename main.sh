i=0
tapIpCounter=1
subnetCounter=0
nodecount=$(($1-1))
echo "creating ${nodecount} process"

echo del vmIp2 | redis-cli
pkill -f keepLiveNodeApp                              # kill all previous background process
pkill -f nodeapp

while [ "$i" -le  $nodecount ];
do
    if [ $(( ($i + 1) % 64 )) -eq 0 ]                 # can get 16384 ip's in host
    then
        subnetCounter=$(( $subnetCounter + 1 ))
        tapIpCounter=1
    fi
   
    tapIp="172.17.$subnetCounter.$tapIpCounter"       # change this according to your available local ip's
    tapIpCounter=$(( $tapIpCounter + 4 ))

    echo "setting up env for ip:$tapIp"
    sh createInterface.sh $tapIp $i
    echo "$tapIp" >> iplist                           # list of local ip address 

    echo lpush vmIp2 $tapIp | redis-cli 

    sh keepLiveNodeApp.sh $tapIp &
    result="nok"
    while [ "$result" != "ok" ]                      # health check
    do
        result="`wget -qO- http://$tapIp:6447/check`"
        echo "-------------result:${result}, http://$tapIp:6447/check"
    done

    i=$(($i+1)) 
done

pm2 start loadBalancer.js -i 5 -n load &
ab -n 500 -c 500 -k  http://localhost:6448/execute 

# check logs at /root/.pm2/logs/load-out-1.log
