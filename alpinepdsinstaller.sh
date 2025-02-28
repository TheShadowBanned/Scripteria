#!/usr/bin/env sh

## This straight forward script turns a fresh installation of a standard Alpine Linux into a Bluesky personal data server
## BEWARE: USE AT YOUR OWN RISK!!
## It has been written and tested on alpine 21 in a LXC on proxmox
## The script will only install the PDS, not run it!
## It is CRUCIAL that you have a working pds.env file PREPARED!!
## Same applies to your DNS entries, externel proxy configs, certificates and so on.

# Secure generator comands
GENERATE_SECURE_SECRET_CMD="openssl rand --hex 16"

# Variables for pds.env
PDS_HOSTNAME=""
PDS_JWT_SECRET="$GENERATE_SECURE_SECRET_CMD"
PDS_ADMIN_PASSWORD=""
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=""
PDS_EMAIL_SMTP_URL=""
PDS_EMAIL_FROM_ADDRESS=""

PDS_DATA_DIRECTORY=./data
PDS_BLOBSTORE_DISK_LOCATION=./data/blocks
PDS_DID_PLC_URL=https://plc.directory
PDS_BSKY_APP_VIEW_URL=https://api.bsky.app
PDS_BSKY_APP_VIEW_DID=did:web:api.bsky.app
PDS_REPORT_SERVICE_URL=https://mod.bsky.app
PDS_REPORT_SERVICE_DID=did:plc:ar7c4by46qjdydhdevvrndac
PDS_CRAWLERS=https://bsky.network
LOG_ENABLED=true
NODE_ENV=production
PDS_PORT=3000

# Warning and some info on what we are about to do

echo "This is a quick an dirty setup script for Bluesky PDS without Docker!"
echo "###"
echo "USE A CLEAN ALPINE LINUX SYSTEM TO RUN OR THINGS WILL BREAK!!!"
sleep 5
echo "###"
echo "It will install nodejs and all necessary components to run the PDS itself and pdsadmin."
echo "###"
echo "It will also help you to create a pds.env file with your domain and personal keys."
sleep 5
echo "###"
echo "It will NOT configure a webserver or proxy for you to get you online straight away! You will have to do that yourself!"
echo "###"
echo "This also applies to everything DNS, as well as domain entries or certificates of any kind!"
sleep 2
echo "###"
sleep 1
echo "##"
sleep 1
echo "#"
sleep 1
read -p "I am aware of the risk and the prerequisites. I wish to continue. (yes/no) " response
sleep 1
if [ "$response" = "no" ]; then
  echo "Well then. Check back in when you feel more comfortable to give it a try. Thanks, hope to see you soon!"
  sleep 1
  exit 1
fi

echo "###"
echo "Great, let's go then!"
echo "Quick and dirty it is: We bring Alpine up to date and install the necessary components."
sleep 1
echo "ENGAGE!"
echo "###"
apk update && apk upgrade --available
apk add --no-cache curl jq gnupg lsb-release xxd ca-certificates nano openssh openssl git sqlite npm nodejs bash ufw
echo "###"
sleep 2
echo "Nicely done! Let's grab the latest version of the Bluesky PDS git repo and clone it to our directory root."
echo "###"
sleep 2
cd /
git clone https://github.com/bluesky-social/pds.git
echo "###"
sleep 2
echo "If you see a fatal error message just above there already is a folder /pds in the directory root."
echo "###"
sleep 5
echo "CAUTION! If you proceed further your pds.env will be overwritten! New keys will be created and your old PDS will be gone! Be sure that this is what you want!"
echo "###"
sleep 2
read -p "Everything is as it's supposed to be  and I wish to continue creating a new PDS.(yes/no) " response
sleep 2
if [ "$response" = "no" ]; then
  echo "###"
  echo "Thanks anyway! Wish you all the best!"
  sleep 2
  exit 1
fi
echo "###"
sleep 2
cd /pds
mkdir service/data
mkdir service/data/blocks 
echo "If you see error messages from mkdir just above it only means that the folders are already there. You can safely ignore that."
echo "###"
sleep 5
echo "You need to provide some information about your PDS to create the new(!) pds.env file for it:"
echo "###"
sleep 1
echo "##"
sleep 1
echo "#"
sleep 1
echo -e "\nPlease enter the domain name of your PDS (e.g. bsky.example.com):"
read -p "PDS Domain: " PDS_HOSTNAME
echo "###"
echo -e "\nPlease enter the email adress that you send mails from your PDS via smtp :"
read -p "PDS email adress for smtp: " PDS_EMAIL_FROM_ADDRESS
echo "###"
echo -e "\nPlease enter the smtp url with login credentials for the above email adress :"
read -p "PDS email smtp url: " PDS_EMAIL_SMTP_URL
echo "###"
echo "Alpine's busybox interpreter cannot perform all the key calculations, you will have to generate them on another machine."
echo "To do this copy the command shown just below and execute it in your Linux or Windows terminal:"
echo "###"
echo "openssl ecparam --name secp256k1 --genkey --noout --outform DER | tail --bytes=+8 | head --bytes=32 | xxd --plain --cols 32"
echo "###"
echo "You need two codes so execute the command twice. The codes will show in the command line."
echo "###"
sleep 1
echo "##"
sleep 1
echo "#"
sleep 1
echo -e "\nPlease enter the FIRST key you just generated :"
read -p "Generated PDS admin password: " PDS_ADMIN_PASSWORD
echo "###"
echo -e "\nPlease enter the SECOND key you just generated :"
read -p "Generated PDS rotation key: " PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX
echo "###"
sleep 2
echo "Great! Let's create your pds.env file."
sleep 1
echo "###"
sleep 1
echo "##"
sleep 1
echo "#"
sleep 1
cat > pds.env << EOF
PDS_HOSTNAME=${PDS_HOSTNAME}
PDS_EMAIL_FROM_ADDRESS=${PDS_EMAIL_FROM_ADDRESS}
PDS_EMAIL_SMTP_URL=${PDS_EMAIL_SMTP_URL}
PDS_JWT_SECRET=$(eval "${GENERATE_SECURE_SECRET_CMD}")
PDS_ADMIN_PASSWORD=${PDS_ADMIN_PASSWORD}
PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX=${PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX}
PDS_DATA_DIRECTORY=${PDS_DATA_DIRECTORY}
PDS_BLOBSTORE_DISK_LOCATION=${PDS_DATA_DIRECTORY}/blocks
PDS_BLOB_UPLOAD_LIMIT=52428800
PDS_DID_PLC_URL=${PDS_DID_PLC_URL}
PDS_BSKY_APP_VIEW_URL=${PDS_BSKY_APP_VIEW_URL}
PDS_BSKY_APP_VIEW_DID=${PDS_BSKY_APP_VIEW_DID}
PDS_REPORT_SERVICE_URL=${PDS_REPORT_SERVICE_URL}
PDS_REPORT_SERVICE_DID=${PDS_REPORT_SERVICE_DID}
PDS_CRAWLERS=${PDS_CRAWLERS}
LOG_ENABLED=true
NODE_ENV=production
PDS_PORT=3000
EOF
echo "Provided you entered your data correctly your pds.env file should now be configured, in place and ready to go!"
echo "###"
echo "Now let's install your Bluesky PDS with npm/nodejs into your Alpine system.This will take a moment. Please be patient!"
sleep 1
echo "###"
sleep 1
echo "##"
sleep 1
echo "#"
sleep 1
cd /pds/service
npm install --production --frozen-lockfile
echo "###"
echo "If you see no error messages your PDS should now be installed and is basically read to go."
echo "###"
echo "For convenience however this script will now modify pdsadmin to work with our PDS on Alpine. It will also configure a service to perform start/stop operations more easily."
sleep 1
echo "###"
sleep 1
echo "##"
sleep 1
echo "#"
sleep 1
ln -s /pds/pdsadmin.sh /usr/local/bin/pdsadmin
chmod +x /usr/local/bin/pdsadmin
sed -i 's|^#!/bin/bash$|#!/usr/bin/env bash|' /usr/local/bin/pdsadmin
echo "The pdsadmin command should now be available on your system."
echo "###"
echo "The script will now install a service for your PDS and make it run on boot."
echo "###"

cat > /etc/init.d/pds << EOF
#!/sbin/openrc-run

name="pds"
description="atproto personal data server"
supervisor="supervise-daemon"
command="/usr/bin/node"
command_args="--env-file=/pds/pds.env --enable-source-maps index.js"
supervise_daemon_args=" -d /pds/service"
EOF

sleep 1
echo "##"
chmod +x /etc/init.d/pds
rc-update add pds default
sleep 1
echo "#"
sleep 1
echo "Done! You can now start and stop your PDS with the 'pds' command. Like this for example: 'service pds start'."
sleep 5
echo "###"
echo "Let's configure and enable ufw as a firewall for good practice."
sleep 1
echo "###"
ufw limit in ssh
sleep 1
echo "##"
ufw allow in ${PDS_PORT}/tcp
sleep 1
echo "#"
sleep 1
echo "y" | ufw enable
echo "###"
echo "Alright, that should be it! Your system is configured and your PDS is ready to run!"
echo "###"
read -p "Would you like to reboot your machine now? (yes/no) " response
sleep 2
if [ "$response" = "no" ]; then
  echo "###"
  echo "Then this installer script has now finished. I strongly suggest that you manually check if it starts and runs smoothly and can be reached from the Internet, can send mails etc..."
  echo "###"
  echo "You may then create an account or create invite codes with pdsadmin the usual way as shown in the Bluesky PDS docs."
  echo "Hope this worked for you! See you soon on Bluesky maybe! Bye! (;"
  echo "Exiting..."
  echo "###"
  sleep 1
  echo "##"
  sleep 1
  echo "#"
  sleep 1
  echo "Script closed"
  exit 1
fi

echo "This installer script will now exit and reboot your system!"
echo "###"
echo "I strongly suggest that you manually check if it is started, runs smoothly and can be reached from the Internet, can send mails etc..."
echo "###"
echo "You may then create an account or create invite codes with pdsadmin the usual way as shown in the Bluesky PDS docs."
echo "###"
echo "Hope this worked for you! See you soon on Bluesky maybe! Bye! (;"
echo "###"
sleep 1
echo "##"
sleep 1
echo "#"
sleep 1
echo "Rebooting now..."
sleep 1
reboot