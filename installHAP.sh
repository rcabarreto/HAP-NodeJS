#1/bin/bash

CURDIR=`pwd`

cd 

if [ `whoami` != 'root' ]; then
  echo "You need to run this script as ROOT!"; exit;  
else

  apt-get update
  apt-get -y remove node nodejs nodejs-legacy
  apt-get -y install git-core libnss-mdns libavahi-compat-libdnssd-dev

  if uname -m | grep -q "armv6l"; then
      clear
      echo "legacy Raspberry Pi detected"
      sleep 1
      wget http://node-arm.herokuapp.com/node_latest_armhf.deb
      dpkg -i node_latest_armhf.deb
      rm -rf node_latest_armhf.deb
  else
      curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
      apt-get install -y nodejs
  fi

  apt-get -y install gcc g++ make
  npm install -g node-gyp

  cd HAP-NodeJS/

  rm -rf accessories/AirConditioner_accessory.js
  npm install

  cd "$CURDIR"

  if type mosquitto>/dev/null; then
    echo "Mosquitto already installed, continuing with install"
  else
    echo "Mosquitto not detected, installing Mosquitto now"
    if cat /etc/os-release | grep -q "jessie"; then
      clear
      wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
      apt-key add mosquitto-repo.gpg.key
      rm -rf mosquitto-repo.gpg.key
      cd /etc/apt/sources.list.d/
      wget http://repo.mosquitto.org/debian/mosquitto-jessie.list
      apt-get update
      apt-get install mosquitto mosquitto-clients -y
    elif cat /etc/os-release | grep -q "stretch"; then
      clear
      echo "stretch set as raspbian release"
      wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
      apt-key add mosquitto-repo.gpg.key
      rm -rf mosquitto-repo.gpg.key
      cd /etc/apt/sources.list.d/
      wget http://repo.mosquitto.org/debian/mosquitto-stretch.list
      apt-get update
      apt-get install mosquitto mosquitto-clients -y
    fi
  fi

  cd "$CURDIR"

  npm install mqtt --save

  cp $CURDIR/runscripts/hapnodejs /etc/init.d/hapnodejs
  cp $CURDIR/runscripts/hapnodejs.default /etc/default/hapnodejs

  echo "Ready to start"; exit;  

fi;
