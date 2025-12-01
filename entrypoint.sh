#!/bin/sh

MODE=${MODE:-default}

# If volume is empty, copy initial application files
if [ -z "$(ls -A /var/www/mikhmon)" ]; then
  echo "Initializing mikhmon data into volume..."
  cp -R /tmp/mikhmon/* /var/www/mikhmon/
  chown -R www-data:www-data /var/www/mikhmon
else
  echo "Volume already contains data, skipping copy."
fi

# Start supervisord first so socket is created
supervisord -c /etc/supervisor/conf.d/supervisord.conf &

# Wait for supervisord socket available
sleep 1

if [ "$MODE" = "caddy" ]; then
  echo "Mode CADDY: start php-fpm only"
  supervisorctl stop nginx
  supervisorctl start php-fpm
else
  echo "Mode DEFAULT: start php-fpm & nginx"
  supervisorctl start php-fpm
  supervisorctl start nginx
fi

# keep container alive (attach foreground)
tail -f /var/log/supervisord.log
