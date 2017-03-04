#!/bin/sh
LIST_KEEP="j2sdk-1_4_2_04-linux-i586.bin
jdk-1_5_0_07-linux-i586.bin
jdk-1_5_0_16-linux-i586.bin
jdk-1_5_0_19-linux-i586.bin
jdk-6u20-linux-i586.bin
jdk-6u33-linux-i586.bin
jdk-7u7-linux-i586.tar.gz
jdk-7u65-linux-i586.tar.gz"

for path in $(ls | grep ^jdk)
do
    oldpath=$path
    path=$(echo $path|cut -d- -f2|tr . _)
    version=$(echo $path | cut -d _ -f2)
    minversion=$(echo $(( $(echo $path | cut -d _ -f4) * 1 )))
    if [[ $(echo $LIST_KEEP | grep $path) ]]
    then
        echo $path
    elif [[ $(echo $LIST_KEEP | grep "${version}u${minversion}") ]]
    then
        echo $path
    else
        rm -rf $oldpath/*{.bin,.gz}
    fi
done
