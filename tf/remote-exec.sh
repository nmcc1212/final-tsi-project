sleep 120
sudo chmod a+wx /etc/nginx/sites-available
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
cat <<EOL > /etc/nginx/sites-available/nial.netbuildertraining.com
server {
  listen 80;
  listen [::]:80;
  server_name nial.netbuildertraining.com;
  location / {
    proxy_pass http://$PRIVATE_IP:3000;
    include proxy_params;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
  }
}
EOL
sudo ln -s /etc/nginx/sites-available/nial.netbuildertraining.com /etc/nginx/sites-enabled/