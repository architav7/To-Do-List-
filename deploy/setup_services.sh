#!/bin/bash
set -e

echo "==> Updating /etc/systemd/system/gunicorn.service..."
sudo bash -c 'cat << "EOF" > /etc/systemd/system/gunicorn.service
[Unit]
Description=Gunicorn daemon for No-Procrastination
After=network.target

[Service]
User=ubuntu
Group=www-data
RuntimeDirectory=gunicorn
WorkingDirectory=/home/ubuntu/No-Procrastination
ExecStart=/home/ubuntu/No-Procrastination/venv/bin/gunicorn \
          --access-logfile - \
          --error-logfile - \
          --workers 3 \
          --bind unix:/run/gunicorn/gunicorn.sock \
          --umask 007 \
          noprocrastination.wsgi:application
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF'

echo "==> Updating /etc/nginx/sites-available/todo..."
sudo bash -c 'cat << "EOF" > /etc/nginx/sites-available/todo
server {
    listen 80;
    listen [::]:80;
    server_name todo.architaverma.tech 15.252.88.147;

    client_max_body_size 20M;

    location = /favicon.ico { 
        access_log off; 
        log_not_found off; 
    }

    location /static/ {
        alias /home/ubuntu/No-Procrastination/staticfiles/;
        expires 30d;
        add_header Cache-Control "public, no-transform";
    }

    location / {
        proxy_pass http://unix:/run/gunicorn/gunicorn.sock;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF'

echo "==> Reloading systemd and restarting gunicorn..."
sudo systemctl daemon-reload
sudo systemctl restart gunicorn
sleep 2

echo "==> Checking Gunicorn status..."
sudo systemctl status gunicorn --no-pager

echo "==> Checking socket file..."
ls -la /run/gunicorn/gunicorn.sock

echo "==> Testing Nginx configuration and restarting..."
sudo nginx -t
sudo systemctl restart nginx

echo "==> Testing local curl to Nginx..."
curl -s -H "Host: todo.architaverma.tech" http://127.0.0.1/ | head -n 35
