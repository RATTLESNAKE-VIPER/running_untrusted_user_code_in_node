i=0
tapIpCounter=1
subnetCounter=0
nodecount=$(($1-1))
echo "creating ${nodecount} process"

# kill all previous background process
echo del vmIp2 | redis-cli
pkill -f keepLiveNodeApp                              
pkill -f nodeapp

# creating multipl2 interface and node process
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

    # store ip in redis 
    echo lpush vmIp2 $tapIp | redis-cli   

    # start nodejs server in background
    sh keepLiveNodeApp.sh $tapIp &
    
    # check weather node server has started successfully
    result="nok"
    while [ "$result" != "ok" ]                      
    do
        result="`wget -qO- http://$tapIp:6447/check`"
    done

    i=$(($i+1)) 
done

# start 5 loadbalancer using pm2
pm2 start loadBalancer.js -i 5 -n load &

# load test
ab -n 500 -c 500 -k  http://localhost:6448/execute 

