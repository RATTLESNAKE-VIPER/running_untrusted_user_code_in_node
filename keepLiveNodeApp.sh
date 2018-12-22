ip=$1

while [ 1 ];                      # health check
do
    node nodeapp.js $ip
done