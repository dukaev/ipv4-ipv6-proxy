#!/bin/bash
# Note: This script changes the proxies such that they all have the same
# user/pass as I have not found a way to keep the randomly generated 
# user/pass intact over rotations.

random() {
	tr </dev/urandom -dc A-Za-z0-9 | head -c5
	echo
}

array=(1 2 3 4 5 6 7 8 9 0 a b c d e f)
gen64() {
	ip64() {
		echo "${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}${array[$RANDOM % 16]}"
	}
	echo "$1:$(ip64):$(ip64):$(ip64):$(ip64)"
}

gen_data() {
    seq $FIRST_PORT $LAST_PORT | while read port; do
        echo "usr$(random)/pass$(random)/$IP4/$port/$(gen64 $IP6)"
    done
}

gen_3proxy() {
    cat <<EOF
daemon
maxconn 500
nscache 65536
nscache6 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
stacksize 262144
flush
auth strong

users usrlolxd:CL:passlolxd

$(awk -F "/" '{print "auth strong\n" \
"allow usrlolxd \n" \
"proxy -6 -n -a -p" $4 " -i" $3 " -e"$5"\n" \
"flush\n"}' ${WORKDATA})
EOF
}

gen_iptables() {
    cat <<EOF
    $(awk -F "/" '{print "iptables -I INPUT -p tcp --dport " $4 "  -m state --state NEW -j ACCEPT"}' ${WORKDATA}) 
EOF
}

gen_ifconfig() {
    cat <<EOF
$(awk -F "/" '{print "ifconfig eth0 inet6 add " $5 "/64"}' ${WORKDATA})
EOF
}

echo "working folder = /home/proxy-installer"
WORKDIR="/home/proxy-installer"
WORKDATA="${WORKDIR}/data.txt"
cd $WORKDIR

IP4=$(curl -4 -s ifconfig.co)
IP6=$(curl -6 -s ifconfig.co | cut -f1-4 -d':')
COUNT=500

FIRST_PORT=10000
LAST_PORT=$(($FIRST_PORT + $COUNT))

gen_data >$WORKDIR/data.txt
gen_iptables >$WORKDIR/boot_iptables.sh
gen_ifconfig >$WORKDIR/boot_ifconfig.sh
gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg

bash $WORKDIR/boot_iptables.sh
bash $WORKDIR/boot_ifconfig.sh

systemctl restart 3proxy