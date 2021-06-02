#!/bin/bash

#Simple SSH script

#Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

#Add clsupport user
PASS=`< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c12`
if grep -q clsupport /etc/passwd; then
    echo "clsupport user exists"
else
    useradd -p $(openssl passwd -1 $PASS) clsupport
echo "clsupport user successfully created"
fi

#Add clsupport to wheel
if grep -q "wheel.*clsupport" /etc/group; then
    echo "clsupport is already in wheel group"
else
    usermod -aG wheel clsupport
    echo "clsupport user added to wheel group"
fi

#Add CL ssh-key
if grep -q clsupport /root/.ssh/authorized_keys; then
    echo "ssh key is already added"
else
    echo ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAgEA0kzTrtnpG3awsKlQRzo8tLzG0Rb93XO6plRtFsVmAtqyuk1nfwC36ISL+AT2+r4+xuZiK8taVgbPVDU/+dHD3ObMQPIvIZOvQWGZH0zZApeXfbKD3DaLfh5aQeI9kbeo3cGQufFIxTkSLVXHTmjISf3gggP7m17hI4jxiu5Gaw/lNwlrQtsBgyEsF4+Y5jSOn1fMkx+R//8ul6L97EBEIGA9Pzcy4tHtTCNxfAGOmUmx8ijnieqNb95wxU5hrhirmWbICeMkgECEsIOPkweWoBNmrVxAigSQuM0uJZeFl5x2I5KaocmXbpeswDCWjGCtEDjcY9WqBSGehuUxArZvGEcaeJ+AM+xIlr0yPTx+3y4JsN/hluzRX9vbuzBZxhctP0BALu8uXKjYvJr9STU0umNZrRHBBQKCIF16FPwcJ7d+H4KYFvxOiVTDKtIZJ5gCtp/nUtVeQFUPEwgirgypP4hv3gkE73A+2vl3lwZ1p2YBmzzbAOpeXDtDFNSpK6Kfa7ujK70ouM0EDptPe/aGJMuDet7RGlnn/zQdpXrCLpUZSVrsTFjN+NZ6uTah5r5QsOhTpL1IoD+FrW9ovgr6KwtM6rl/XKzrzmbnQGaGQY5h5Kan2a0Y24eIXm5MnncOgwZZUCpT7SV2b7cjASf5xMfU87Ihe3c/Vmi33pblD8E= clsupport@sshbox.cloudlinux.com >> /root/.ssh/authorized_keys
    echo -e "ssh key for clsupport has been added \nssh service will be restarted"
    service sshd restart
fi

#Add firewall whitelist
if iptables-save | grep -qE "69.175.3.6.*ACCEPT|23.111.175.21.*ACCEPT"; then
    echo "CL IP's are already whitelisted"
else
    iptables -A INPUT -s 23.111.175.214 -j ACCEPT
    iptables -A OUTPUT -s 23.111.175.214 -j ACCEPT
    iptables -A INPUT -s 69.175.3.6 -j ACCEPT
    iptables -A OUTPUT -s 69.175.3.6 -j ACCEPT
    echo -e "CL IP's has been added to iptables whitelist \n They will be removed after reboot"
fi

PORT=`grep "Port " /etc/ssh/sshd_config | cut -d" " -f2`
IP=`curl http://cloudlinux.com/showip.php -s`
echo -e "Please provide this string to the CL support team: \nssh clsupport@$IP -p $PORT \nsudo pass is $PASS"
