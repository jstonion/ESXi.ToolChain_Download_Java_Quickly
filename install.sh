#!/bin/bash

read -p "Path to src (/build/toolchain/src): " SETUP_PATH
if [[ $SETUP_PATH=="" ]]; then SETUP_PATH=/build/toolchain/src; fi
if [[ ! -e $SETUP_PATH ]]
then
  echo "$SETUP_PATH is not exist"\!
  exit(1)
fi
cp expat-1.95.8.tar.gz pull.sh $SETUP_PATH
chmod 755 pull.sh redhat7x86_fix.sh
cd $SETUP_PATH
tar xzf expat-1.95.8.tar.gz
cd expat-1.95.8
./configure
make && make install
cd ..
./pull.sh
./redhat7x86_fix.sh
echo DONE\!\!\!
