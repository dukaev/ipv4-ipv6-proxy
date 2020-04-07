#!/bin/sh
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
        echo "$IP_AUTHORIZATION/$IP4/$port/$(gen64 $IP6)"
    done
}

gen_3proxy() { 
    cat <<EOF
daemon
maxconn 1000
nscache 65536
nscache6 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
stacksize 262144
flush
auth iponly

$(awk -F "/" '{print "auth iponly\n" \
"allow * " $1 "\n" \
"proxy -6 -n -a -p" $3 " -i" $2 " -e"$4"\n" \
"flush\n"}' ${WORKDATA})
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
IP_AUTHORIZATION=

gen_data >$WORKDIR/data.txt
gen_3proxy >/usr/local/etc/3proxy/3proxy.cfg

systemctl stop 3proxy
systemctl start 3proxy
