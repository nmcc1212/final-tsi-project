sudo apt-get update -y
sudo apt-get install ca-certificates curl wget gnupg nginx -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -aG docker ubuntu
sudo usermod -aG docker root

git clone https://github.com/nmcc1212/final-tsi-project.git
cd final-tsi-project/tf
docker compose up

sudo systemctl start nginx
sudo systemctl enable nginx

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