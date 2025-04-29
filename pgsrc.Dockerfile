FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install PostgreSQL 11
RUN apt-get update && \
    apt-get install -y wget gnupg2 lsb-release curl && \
    echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
      > /etc/apt/sources.list.d/pgdg.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y postgresql-11 && \
    apt-get install -y rsync && \
    # apt-get install -y openssh-server sudo && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure SSH
# RUN mkdir /var/run/sshd
# RUN echo "postgres:123456" | chpasswd

# Allow root login
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix
# RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

# # Create SSH directory and set permissions
# RUN mkdir -p /var/lib/postgresql/.ssh
# RUN chmod 700 /var/lib/postgresql/.ssh

# Configure SSH for the user
# RUN mkdir -p /home/postgres/.ssh && \
#     chmod 700 /home/postgres/.ssh

# # Copy the authorized_keys file
# COPY barman/id_rsa.pub /var/lib/postgresql/.ssh/authorized_keys
# RUN chmod 600 /var/lib/postgresql/.ssh/authorized_keys

# Copy public key
# COPY keys/id_rsa.pub /var/lib/postgresql/.ssh/authorized_keys

# Set correct permissions
# RUN chmod 600 /var/lib/postgresql/.ssh/authorized_keys && \
    # chown -R postgres:postgres /var/lib/postgresql/.ssh


# SSH configuration - enable public key auth and disable password auth
# RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    # sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Copy your init SQL file
COPY postgres/init.sql /init.sql




# COPY postgres/init.sql /docker-entrypoint-initdb.d/init.sql
# COPY postgres/postgresql.conf /var/lib/postgresql/11/main/postgresql.conf 
# COPY postgres/pg_hba.conf /var/lib/postgresql/11/main/pg_hba.conf
# COPY postgres/pg_ctl.conf /var/lib/postgresql/11/main/pg_ctl.conf
# COPY postgres/pg_ident.conf /var/lib/postgresql/11/main/pg_ident.conf
COPY postgres/postgresql.conf /etc/postgresql/11/main/postgresql.conf 
COPY postgres/pg_hba.conf /etc/postgresql/11/main/pg_hba.conf
COPY postgres/pg_ctl.conf /etc/postgresql/11/main/pg_ctl.conf
COPY postgres/pg_ident.conf /etc/postgresql/11/main/pg_ident.conf

# ENV POSTGRES_USER=postgres
# ENV POSTGRES_PASSWORD=secret
# ENV POSTGRES_DB=company

# Expose PostgreSQL port
EXPOSE 5432
# EXPOSE 22

# Keep container running
CMD bash -c "service postgresql start && sleep 5 && createdb -U postgres company && psql -U postgres -h localhost -d company -f /init.sql && tail -f /dev/null"
# CMD ["sh", "-c", "service postgresql start && tail -f /dev/null"]



# run in baman server
# chmod 600 ~/.ssh/id_rsa
# docker-compose -f db.yml up --build -d