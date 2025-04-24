FROM ubuntu:latest

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Add PostgreSQL repository
RUN apt-get update && apt-get install -y wget gnupg lsb-release
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

# Install Barman and required packages
RUN apt-get update && apt-get install -y \
    barman \
    postgresql-client \
    openssh-client \
    rsync \
    cron \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create required directories
RUN mkdir -p /etc/barman.d /var/log/barman /var/lib/barman/.ssh

# Copy SSH keys from build context directly into the image
COPY keys/id_rsa /var/lib/barman/.ssh/id_rsa
COPY keys/id_rsa.pub /var/lib/barman/.ssh/id_rsa.pub

# Set proper permissions for SSH files
RUN chmod 700 /var/lib/barman/.ssh && \
    chmod 600 /var/lib/barman/.ssh/id_rsa && \
    chmod 644 /var/lib/barman/.ssh/id_rsa.pub

# Create SSH config file
RUN echo "Host pg_server\n\
  IdentityFile /var/lib/barman/.ssh/id_rsa\n\
  User postgres\n\
  StrictHostKeyChecking no" > /var/lib/barman/.ssh/config && \
  chmod 600 /var/lib/barman/.ssh/config

# Copy configuration files
COPY barman/barman.conf /etc/barman.conf
COPY barman/pg.conf /etc/barman.d/
# COPY supervisord.conf /etc/supervisor/conf.d/barman.conf

# Set ownership
RUN chown -R barman:barman /var/lib/barman /etc/barman.d /var/log/barman /etc/barman.conf

# Create entrypoint script
# COPY barman/entrypoint.sh /entrypoint.sh
# RUN chmod +x /entrypoint.sh

# Create cron job for periodic backups
# RUN echo "0 3 * * * barman /usr/bin/barman backup all >> /var/log/barman/backup.log 2>&1" > /etc/cron.d/barman-backup
# RUN chmod 0644 /etc/cron.d/barman-backup

# VOLUME ["/var/lib/barman", "/etc/barman.d", "/var/log/barman"]

# ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n"]
# CMD ["/bin/bash"]