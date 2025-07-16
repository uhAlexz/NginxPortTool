#!/bin/bash

clear
echo ""
echo "╔════════════════════════════════╗"
echo "║     ⚙️  NGINX Config Tool      ║"
echo "╚════════════════════════════════╝"
echo ""

read -p "🌐 Enter your domain (e.g. lo.uhalexz.xyz): " DOMAIN
read -p "🔌 Enter the port your app runs on (e.g. 9000): " PORT

if [[ -z "$DOMAIN" || -z "$PORT" ]]; then
  echo "❌ Both domain and port are required."
  exit 1
fi

NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"

echo ""
echo "📝 Creating NGINX config for $DOMAIN..."

sudo tee $NGINX_CONF >/dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

sudo ln -sf $NGINX_CONF /etc/nginx/sites-enabled/

echo "🔁 Reloading nginx..."
sudo nginx -t && sudo systemctl reload nginx

echo "🔐 Requesting SSL cert from Let's Encrypt..."
sudo certbot --nginx -d $DOMAIN

echo ""
echo "✅ All done! Your site is live at: https://$DOMAIN"
