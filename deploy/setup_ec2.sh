#!/bin/bash
set -e

cd /home/ubuntu/No-Procrastination
chmod -R 755 /home/ubuntu/No-Procrastination

echo "==> Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

echo "==> Upgrading pip and installing requirements..."
./venv/bin/pip install --upgrade pip
./venv/bin/pip install -r requirements.txt

echo "==> Running migrations..."
./venv/bin/python manage.py migrate

echo "==> Collecting static files..."
./venv/bin/python manage.py collectstatic --noinput

echo "==> Setting directory and database ownership..."
sudo chown -R ubuntu:www-data /home/ubuntu/No-Procrastination
sudo chmod -R 775 /home/ubuntu/No-Procrastination
sudo chmod 664 /home/ubuntu/No-Procrastination/db.sqlite3

echo "==> Verifying Gunicorn can import WSGI application..."
./venv/bin/python -c "import noprocrastination.wsgi; print('WSGI imported successfully!')"

echo "==> Django environment setup complete!"
