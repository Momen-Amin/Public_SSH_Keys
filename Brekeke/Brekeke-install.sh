#!/bin/bash

# Update package lists
apt -y update

# Upgrade installed packages
apt -y upgrade

BASE_DIR=/opt/brekeke
TOMCAT_DIR=$BASE_DIR/tomcat
BREKEKE_DIR=$BASE_DIR/sip

TOMCAT_FILE=apache-tomcat-8.5.97.tar.gz
BREKEKE_FILE=sip3_14_7_4.zip
POSTGRESQL_FILE=postgresql-42.7.1.jar

TOMCAT_URL=https://raw.githubusercontent.com/Momen-Amin/Public_Scripts/main/Brekeke/apache-tomcat-8.5.97.tar.gz
BREKEKE_URL=https://raw.githubusercontent.com/Momen-Amin/Public_Scripts/main/Brekeke/sip3_14_7_4.zip
POSTGRESQL_URL=https://raw.githubusercontent.com/Momen-Amin/Public_Scripts/main/Brekeke/postgresql-42.7.1.jar
SERVERXML_FILE=$TOMCAT_DIR/conf/server.xml
TOMCAT_USER=tomcat
TOMCAT_USER_FOLDER=/home/$TOMCAT_USER
START_PORT=8080
END_PORT=8099

export DEBIAN_FRONTEND=noninteractive

# Check available port
for port in $(seq $START_PORT $END_PORT); do
    if ! nc -z -v -w1 localhost $port &>/dev/null; then
        PORT=$port
        break
    fi
done


if [ -d "$BASE_DIR" ]; then
    rm -rf $BASE_DIR
fi

mkdir -p $BASE_DIR
mkdir -p $TOMCAT_DIR

# Install required packages using apt-get (for Debian/Ubuntu-based systems)
if [ -x "$(command -v apt-get)" ]; then
    apt-get -y -o Dpkg::Options::="--force-confold" install libc6-i386 libc6-x32 libxi6 libxrender1 libxtst6 unzip default-jre
else
    # Add package installation commands for other package managers as needed
    echo "Package installation not supported on this system."
    exit 1
fi

wget -P $BASE_DIR $BREKEKE_URL
wget -P $BASE_DIR $TOMCAT_URL
wget -P $BASE_DIR $POSTGRESQL_URL

unzip -j $BASE_DIR/$BREKEKE_FILE -d $BREKEKE_DIR
tar xzvf $BASE_DIR/$TOMCAT_FILE -C $TOMCAT_DIR --strip-components=1

cp $SERVERXML_FILE $SERVERXML_FILE.backup
sed -i 's/unpackWARs="true" autoDeploy="true">/unpackWARs="true" autoDeploy="false" liveDeploy="false" xmlValidation="false" xmlNamespaceAware="false">/' $TOMCAT_DIR/conf/server.xml
sed -i "s/8080/$PORT/g" $TOMCAT_DIR/conf/server.xml

# Check if the TOMCAT_USER already exists
if id $TOMCAT_USER >/dev/null 2>&1; then
    echo "User $TOMCAT_USER already exists"
else
    useradd -m -d $TOMCAT_USER_FOLDER -U -s /bin/false $TOMCAT_USER
fi

# Check if a port was found
if [ -z "$PORT" ]; then
    echo "Error: Unable to find a free port between $START_PORT and $END_PORT."
    exit 1
fi

chown -R $TOMCAT_USER:$TOMCAT_USER $TOMCAT_DIR/
chmod -R u+x $TOMCAT_DIR/bin
cp $BREKEKE_DIR/sip.war $TOMCAT_DIR/webapps

# Create systemd unit file for Tomcat if it doesn't exist
if [ ! -f /etc/systemd/system/tomcat.service ]; then
    echo "
[Unit]
Description=Apache Tomcat
After=syslog.target network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=CATALINA_PID=$TOMCAT_DIR/temp/tomcat.pid
Environment=CATALINA_HOME=$TOMCAT_DIR
Environment=CATALINA_BASE=$TOMCAT_DIR

ExecStart=$TOMCAT_DIR/bin/catalina.sh start
ExecStop=$TOMCAT_DIR/bin/catalina.sh stop

RestartSec=12
Restart=always

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/brekeke.service

systemctl daemon-reload
fi

mv $BASE_DIR/$POSTGRESQL_FILE $TOMCAT_DIR/webapps/sip/WEB-INF/lib/$POSTGRESQL_FILE

# Start and enable Tomcat service
systemctl enable brekeke.service
systemctl start brekeke.service
systemctl restart brekeke.service

# Print the URL with a nice border
echo "#########################################################"
echo "##                                                     ##"
echo "##   URL to open: http://$(hostname -I | awk '{print $1}'):$PORT/sip/gate   ##"
echo "##                                                     ##"
echo "#########################################################"
