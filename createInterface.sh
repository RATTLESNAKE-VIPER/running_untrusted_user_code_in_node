ip=$1
id=$2

echo "creating tap interface tap $ip"
sudo ip link del tap$id
sudo ip tuntap add tap$id mode tap 
sudo ip addr add $ip/30 dev tap$id
sudo ip link set tap$id up
sudo sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo iptables -t nat -A POSTROUTING -o wlo1 -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i tap$id -o wlo1 -j ACCEPT
