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
RUN mkdir -p /etc/barman.d /var/log/barman /root/.ssh

# Copy SSH keys from build context directly into the image
COPY conf/keys/id_rsa /root/.ssh/id_rsa
COPY conf/keys/id_rsa.pub /root/.ssh/id_rsa.pub

# Set proper permissions for SSH files
RUN chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 644 /root/.ssh/id_rsa.pub

# Create SSH config file
RUN echo "Host pg_server\n\
  IdentityFile /root/.ssh/id_rsa\n\
  User postgres\n\
  StrictHostKeyChecking no" > /root/.ssh/config && \
  chmod 600 /root/.ssh/config

# Copy configuration files
COPY conf/barman/barman.conf /etc/barman.conf
COPY conf/barman/pg.conf /etc/barman.d/pg.conf
COPY conf/barman/supervisord.conf /etc/supervisor/conf.d/barman.conf

# Set ownership
RUN chown -R barman:barman /var/lib/barman /etc/barman.d /var/log/barman /etc/barman.conf
RUN chmod 700 /var/lib/barman

#New fixes - .lock file missing fix
# RUN chown -R barman:barman /var/lib/barman/backups
RUN mkdir -p /var/lib/barman/.locks
RUN chown barman:barman /var/lib/barman/.locks
RUN chmod 700 /var/lib/barman/.locks/

# RUN barman receive-wal --create-slot pg
# RUN barman switch-xlog --force --archive pg

# Create cron job for daily 3AM backups
# RUN echo "*/2 * * * * barman /usr/bin/barman backup all >> /var/log/barman/backup.log 2>&1" > /etc/cron.d/barman-backup
# RUN chmod 0644 /etc/cron.d/barman-backup

# ENTRYPOINT ["/entrypoint.sh"]
# CMD ["/usr/bin/supervisord", "-n"]
# CMD ["/usr/bin/bash"]

CMD bash -c "service ssh start && tail -f /dev/null"