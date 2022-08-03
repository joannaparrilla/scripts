#!/bin/sh
apt-get update  # To get the latest package lists
apt-get install openjdk-11-jdk -y
apt-get install docker-compose -y
apt-get install unzip -y
apt-get install awscli -y

#add user and add to sudo group
useradd containernode --create-home --shell /bin/bash --groups sudo
#create JenkinsPath
mkdir /home/containernode/jenkins
cd /home/containernode/
chown containernode:containernode jenkins/

#add permissions /var/run/docker.sock cront task
touch /home/containernode/dockerpermission.sh
chmod a+x /home/containernode/dockerpermission.sh
cat > /home/containernode/dockerpermission.sh << ENDOFFILE
#!/bin/bash
sudo chmod 666 /var/run/docker.sock
ENDOFFILE
linetocrontab="@reboot /home/containernode/dockerpermission.sh"
(crontab -u $(whoami) -l; echo "$linetocrontab" ) | crontab -u $(whoami) -

#ssh authentication
mkdir /home/containernode/.ssh
ssh-keygen -t ed25519 -f /home/containernode/.ssh/authorized_keys -q -N "" -C '"containernode"'
cp /home/containernode/.ssh/authorized_keys /home/containernode/.ssh/authorized_keys.private
mv /home/containernode/.ssh/authorized_keys.pub /home/containernode/.ssh/authorized_keys
chown -R containernode:containernode /home/containernode/.ssh/
sudo service sshd restart
#Mostrarme la clave privada para agregar  en Jenkins
cat /home/containernode/.ssh/authorized_keys.private
#Asignar password al usuario y guardarla en keepass
passwd containernode
