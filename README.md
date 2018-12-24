# excute main.sh file
# Get detail article here
https://medium.com/@deepak.r.poojari/running-users-untrusted-code-in-nodejs-930aadf936eb

Running user untrusted code is sometimes challenging to run in NodeJs, as NodeJs runs on a single thread. This thread can be blocked by a user using a while loop in code or the process can be killed using process.exit in vm.

The two main solution’s for this problem is running the user code in Childprocess or using VM module, but this solution’s come with a problem in themselves.
1) Childprocess can communicate with the parent process and can access other user’s data.
2) Node’s official website says “The VM module is not a security mechanism. Do not use it to run untrusted code”.
the main process can be killed inside VM using global.constructor.constructor(‘return this’)().constructor.constructor(‘return process’)().exit(0)

So neither Childprocess nor VM seems to be a good solution for running untrusted code.

“They say Node is not meant for security reason”

but we can make one.

So in this article, I am going to explain you an architecture that will host 1000’s of node process on a single machine which will listen on the same port but different IP's.


For creating a 1000 node process’s with 1000 unique IP’s will have to use reserved local IP’s that range from 172.16.0.0–172.31.255.255 on a private network. (it may vary on your network)

This is how it works.
create 1000 tap interface with unique IP’s, start 1000 node process with that 1000 unique IP’s and after user code execution restart node server so that any malicious code stored by user code execution will not be available in the process.

There might be some microseconds downtime for process restart but Security can never be compromised.

# Step 1: (createInterface.sh)
create 1000 interface (repeat this 1000 times with unique ip and tapid)

# Step 2: (keepLiveNodeApp.sh)
Run node process with IP provided as process arguments.
node nodeapp.js “IP” (IP should be same as tap IP)
This process will restart after every user code execution.

# Step 3: (loadBalancer.js)
Run loadbalancer.js
loadbalancer.js will be that main process that will be responsible for routing the external requests to nodeapp.js process.

loadbalncer will be connected to Redis to get the ip address of a nodeapp process that is Ideal and not executing any user code. after user code execution nodeapp will restart and its IP will be set in redis as Ideal

loadbalancer can also be used for killing nodejs process that has blocked node thread. 
like, 
while(true) console.log(‘blocked’);

killing blocked node process with node come with additional memory requirements and that can be done efficiently using golang.
I will update the code with golang server for killing blocked node process.
