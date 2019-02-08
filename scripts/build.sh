# Build for install
echo "#!/bin/sh" >install.sh

cat system.sh >>install.sh
cat 3proxy.sh >>install.sh
cat main.sh >>install.sh
