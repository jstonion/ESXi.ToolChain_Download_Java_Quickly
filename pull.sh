#!/bin/bash
if [ ! -d "./src" ]
    then
    DOWNLOAD_PATH="."
else
    DOWNLOAD_PATH="./src"
fi
#Login information
echo "Please enter your Oracle account information! You can get 1 free at http://www.oracle.com"
getUsernameAndPassword() {
    read -p "Username: " USERNAME
    read -p "Password: " PASSWORD
    read -p "User: $USERNAME
Password: $PASSWORD
Are you sure? (y/n): " reCheck
}
getUsernameAndPassword
while [ $reCheck != "y" ]
do
    getUsernameAndPassword
done

#Cookie storage
COOKIE=/tmp/cookie

JAVA_1_4=http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase14-419411.html
JAVA_1_5=http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase5-419410.html
JAVA_1_6=http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase6-419409.html
JAVA_1_7=http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html

function Login {
    HTML=$(curl "http://www.oracle.com/webapps/redirect/signon?nexturl=https://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase14-419411.html" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:51.0) Gecko/20100101 Firefox/51.0" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.5" --compressed \
    -H "DNT: 1" \
    -H "Connection: keep-alive" \
    -b $COOKIE \
    -c $COOKIE \
    -L)
    POST_v=$(echo $HTML | grep -oP 'name="v" value="[^"]*"' | rev | cut -d'"' -f2| rev)
    POST_OAM_REQ=$(echo $HTML | grep -oP 'name="OAM_REQ" value="[^"]*"' | rev | cut -d'"' -f2| rev)
    POST_site2pstoretoken=$(echo $HTML | grep -oP 'name="site2pstoretoken" value="[^"]*"' | rev | cut -d'"' -f2| rev)
    POST_locale=$(echo $HTML | grep -oP 'name="locale" value="[^"]*"' | rev | cut -d'"' -f2| rev)

    curl "https://login.oracle.com/oam/server/sso/auth_cred_submit" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:51.0) Gecko/20100101 Firefox/51.0" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.5" --compressed \
    -H "Referer: https://login.oracle.com/mysso/signon.jsp" \
    -H "DNT: 1" \
    -H "Connection: keep-alive" \
    -H "Upgrade-Insecure-Requests: 1" \
    -b $COOKIE \
    -c $COOKIE \
    --data "v="$POST_v"&OAM_REQ="$POST_OAM_REQ"&site2pstoretoken="$POST_site2pstoretokenlocale"&locale="$POST_locale"&ssousername="$USERNAME"&password="$PASSWORD \
    -L -o /dev/null

    #Force Agree with License
    echo -e ".oracle.com\tTRUE\t/\tFALSE\t1995908556\toraclelicense\taccept-securebackup-cookie" >> $COOKIE
}

function Get_Download_Link {
    FILE_PATH=$1
    FILE_NAME=$(echo $FILE_PATH | rev | cut -d/ -f1 | rev)

    JAVA_VERSION=$(echo $FILE_PATH | cut -d. -f2)
    URL=$(eval "echo \$JAVA_1_"$JAVA_VERSION)
    LINK=$(curl $URL -sS | grep -oP 'http[^"]*'$FILE_NAME)
    echo "============================="
    echo "URL: $LINK"
    echo "Path: $DOWNLOAD_PATH/$FILE_PATH"
    echo "Name: $FILE_NAME"
    curl "$LINK" \
    -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:51.0) Gecko/20100101 Firefox/51.0" \
    -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
    -H "Accept-Language: en-US,en;q=0.5" --compressed \
    -H "Referer: $URL" \
    -H "DNT: 1" \
    -H "Connection: keep-alive" \
    -H "Upgrade-Insecure-Requests: 1" \
    -b $COOKIE \
    -c $COOKIE \
    -o "$DOWNLOAD_PATH/$FILE_PATH" -L
    
    #Need to executable, this's missing from VMWare Document
    chmod 755 $DOWNLOAD_PATH/$FILE_PATH
}
#Login first
#clear cookie
echo "" > $COOKIE
Login
#For JDK
for path in $(ls src | grep jdk-1.)
do
    cat $DOWNLOAD_PATH/$path/install.sh | grep -P '^ *PKG' | while read pkg
    do
        FILE_NAME=$(echo $pkg|cut -d= -f2)
        Get_Download_Link $path/$FILE_NAME
    done
done

#JRE
mkdir -p $DOWNLOAD_PATH/jre-redist-1.7.0_17/baseline
LIST_FILE="jre-7u17-linux-i586.rpm
jre-7u17-linux-x64.rpm
jre-7u17-windows-i586.tar.gz
jre-7u17-linux-i586.tar.gz
jre-7u17-linux-x64.tar.gz
jre-7u17-windows-x64.tar.gz"
for FILE_NAME in $LIST_FILE
do
    Get_Download_Link "jre-redist-1.7.0_17/baseline/"$FILE_NAME
done

#http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip
mkdir $DOWNLOAD_PATH/jce_policy-7
LINK="http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip"
curl "$LINK" \
-H "User-Agent: Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:51.0) Gecko/20100101 Firefox/51.0" \
-H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
-H "Accept-Language: en-US,en;q=0.5" --compressed \
-H "Referer: $URL" \
-H "DNT: 1" \
-H "Connection: keep-alive" \
-H "Upgrade-Insecure-Requests: 1" \
-b $COOKIE \
-c $COOKIE \
-o "$DOWNLOAD_PATH/jce_policy-7/UnlimitedJCEPolicyJDK7.zip" -L
