#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
apt-get install apache2 nodejs npm -y
apt-get update -y
apt-get install software-properties-common -y
add-apt-repository universe -y
add-apt-repository ppa:certbot/certbot -y
apt-get update -y
apt-get install certbot python-certbot-apache -y
certbot --apache
mkdir /root/expressredirect
cd /root/expressredirect && npm install express
rm /etc/apache2/ports.conf
echo "# If you just change the port or add more ports here, you will likely also
# have to change the VirtualHost statement in
# /etc/apache2/sites-enabled/000-default.conf

#Listen 80

<IfModule ssl_module>
	Listen 443
</IfModule>

<IfModule mod_gnutls.c>
	Listen 443
</IfModule>

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet">/etc/apache2/ports.conf
echo "const app = require('express')();
const http = require('http');

app.all('*', ensureSecure);

http.createServer(app).listen(80);

function ensureSecure(req, res, next){
    res.redirect('https://'+req.hostname+req.url);
}
" > /root/expressredirect/app.js
crontab -l > mycron
echo "@reboot node /root/expressredirect/app.js" >> mycron
crontab mycron
rm mycron