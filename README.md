![cover](cover.svg)

Auto configurator of ipv4 → ipv6 http proxy. Redirect connections from different ports on one ipv4 address to unique random ipv6 address from \64 subnetwork.

## Requirements
- Centos 7
- Ipv6 \64

## Installation
```
bash <(curl -s "https://raw.githubusercontent.com/dukaev/ipv6_proxy/master/scripts/install.sh")
```
[Video tutorial](https://youtu.be/EKBJHSTmT4w)

[Buy VPS  Vultr](https://www.vultr.com/?ref=7502192)

After installation you can dowload file.
The file is organized like this:
```
IP4:PORT:LOGIN:PASS
```
Use [format](http://buyproxies.org/panel/format.php
) for formatted proxy list

## Testing proxy

Firefox with [FoxyProxy](https://addons.mozilla.org/en-US/firefox/addon/foxyproxy-standard/)
![Foxy](foxyproxy.png)

Go to check [ip6 test](http://ipv6-test.com/)
![check ip](check_ip.png)
