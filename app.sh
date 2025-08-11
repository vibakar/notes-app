#!/bin/bash

set -e

APP_DIR="/home/ec2-user"
FRONTEND_DIR="$APP_DIR/notes-app/frontend"
BACKEND_DIR="$APP_DIR/notes-app/backend"
BACKEND_PORT="3000"
NGINX_HTML_DIR="/usr/share/nginx/html"
POSTGRES_USERNAME="postgres"
POSTGRES_PASSWORD="12345"
POSTGRES_DATABASE="postgres"
SERVER_IP=$(curl -s http://checkip.amazonaws.com)

install_tools() {
  echo "Installing tools: git, nginx, nodejs..."
  dnf install -y git nginx

  # Enable and start nginx
  systemctl enable nginx
  systemctl start nginx

  # Clear nginx default html directory
  rm -rf ${NGINX_HTML_DIR}/*

  # Install Node.js 20
  curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
  dnf install -y nodejs
}

setup_postgres() {
  echo "Setting up PostgreSQL 15..."

  dnf install -y postgresql15 postgresql15-server

  mkdir -p /var/lib/pgsql/15/data
  chown -R postgres:postgres /var/lib/pgsql

  sudo -u postgres /usr/bin/initdb -D /var/lib/pgsql/15/data

  echo "Creating systemd service for PostgreSQL..."
  tee /etc/systemd/system/postgresql-custom.service > /dev/null <<EOF
[Unit]
Description=PostgreSQL Custom
After=network.target

[Service]
Type=forking
User=postgres
ExecStart=/usr/bin/pg_ctl -D /var/lib/pgsql/15/data -l /var/lib/pgsql/15/data/logfile start
ExecStop=/usr/bin/pg_ctl -D /var/lib/pgsql/15/data stop
ExecReload=/usr/bin/pg_ctl -D /var/lib/pgsql/15/data reload
PIDFile=/var/lib/pgsql/15/data/postmaster.pid

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reexec
  systemctl daemon-reload
  systemctl enable --now postgresql-custom

  echo "Setting password for postgres user..."
  sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '${POSTGRES_PASSWORD}';"

  echo "PostgreSQL setup complete."
}

clone_repo() {
  echo "Cloning notes app repository..."
  cd ${APP_DIR}
  git clone https://github.com/vibakar/notes-app.git
}

setup_frontend() {
  echo "Setting up frontend..."
  export VITE_API_BASE_URL="http://${SERVER_IP}:${BACKEND_PORT}"

  cd $FRONTEND_DIR
  npm install
  npm run build

  echo "Copying frontend build to NGINX directory..."
  cp -r dist/* $NGINX_HTML_DIR/
  
  echo "Restarting nginx..."
  systemctl restart nginx
}

setup_backend() {
  echo "Setting up backend..."
  export CORS_ALLOWED_ORIGIN="*"
  export DATABASE_URL="postgresql://${POSTGRES_USERNAME}:${POSTGRES_PASSWORD}@127.0.0.1:5432/${POSTGRES_DATABASE}"
  
  cd $BACKEND_DIR
  npm install
  npm run build

  echo "Starting backend server in background..."
  nohup npm start > output.log 2>&1 &
}


main() {
  echo "Starting Notes App Setup..."
  install_tools
  setup_postgres
  clone_repo
  setup_frontend
  setup_backend
  echo "Deployment complete. Visit http://${SERVER_IP} to access the app."
}

main
