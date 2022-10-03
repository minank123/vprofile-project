#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install openjdk-8-jdk -y
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat
java -version
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.20/bin/apache-tomcat-10.0.23.tar.gz
sudo tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin
sudo nano /opt/tomcat/conf/tomcat-users.xml
#Add the following lines before the ending tag:

<role rolename="manager-gui" />
<user username="manager" password="manager_password" roles="manager-gui" />

<role rolename="admin-gui" />
<user username="admin" password="admin_password" roles="manager-gui,admin-gui" />

sudo nano /opt/tomcat/webapps/manager/META-INF/context.xml
#Comment out the Valve definition, as shown
#...
#<Context antiResourceLocking="false" privileged="true" >
#  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
#                  sameSiteCookies="strict" />
#<!--  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
#         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
#  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.Csr>
#</Context>

sudo nano /opt/tomcat/webapps/host-manager/META-INF/context.xml
#Comment out the Valve definition, as shown
#...
#<Context antiResourceLocking="false" privileged="true" >
#  <CookieProcessor className="org.apache.tomcat.util.http.Rfc6265CookieProcessor"
#                  sameSiteCookies="strict" />
#<!--  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
#         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
#  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.Csr>
#</Context>
sudo update-java-alternatives -l
#Note the path where Java resides, listed in the last column. You’ll need the path momentarily to define the service.
#You’ll store the tomcat service in a file named tomcat.service, under /etc/systemd/system. Create the file for editing by running:
sudo nano /etc/systemd/system/tomcat.service
#Add the following lines:
[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
#Modify the highlighted value of JAVA_HOME if it differs from the one you noted previously.

Here, you define a service that will run Tomcat by executing the startup and shutdown scripts it provides. You also set a few environment variables to define its home directory (which is /opt/tomcat as before) and limit the amount of memory that the Java VM can allocate (in CATALINA_OPTS). Upon failure, the Tomcat service will restart automatically.

When you’re done, save and close the file.

----------------
sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl status tomcat
#Press q to exit the command.
sudo systemctl enable tomcat
#Now that the Tomcat service is running, you can configure the firewall to allow connections to Tomcat. Then, you will be able to access its web interface.

#Tomcat uses port 8080 to accept HTTP requests. Run the following command to allow traffic to that port:
sudo ufw allow 8080
#check web ui from http://your ip:8080
