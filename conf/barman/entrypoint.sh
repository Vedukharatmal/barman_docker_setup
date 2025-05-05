#!/bin/bash
set -e

# Verify SSH keys are present and have proper permissions
# if [ -f /var/lib/barman/.ssh/id_rsa ]; then
#     echo "Verifying SSH key permissions..."
#     chown barman:barman /var/lib/barman/.ssh/id_rsa /var/lib/barman/.ssh/id_rsa.pub /var/lib/barman/.ssh/config
#     chmod 600 /var/lib/barman/.ssh/id_rsa
#     chmod 644 /var/lib/barman/.ssh/id_rsa.pub
#     chmod 600 /var/lib/barman/.ssh/config
#     echo "SSH keys are properly configured"
# else
#     echo "ERROR: SSH keys not found in /var/lib/barman/.ssh/"
#     exit 1
# fi

# Add PostgreSQL server to known_hosts if needed
if [ ! -f /var/lib/barman/.ssh/known_hosts ] || ! grep -q "pg_server" /var/lib/barman/.ssh/known_hosts; then
    echo "Adding PostgreSQL server to known_hosts..."
    su - barman -c "ssh-keyscan pg_server >> /var/lib/barman/.ssh/known_hosts"
fi

# Execute the command passed to the container
exec "$@"
