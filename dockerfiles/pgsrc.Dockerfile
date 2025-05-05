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

# Copy your init SQL file
COPY conf/pgsrc/init.sql /init.sql

COPY conf/pgsrc/postgresql.conf /etc/postgresql/11/main/postgresql.conf 
COPY conf/pgsrc/pg_hba.conf /etc/postgresql/11/main/pg_hba.conf
COPY conf/pgsrc/pg_ctl.conf /etc/postgresql/11/main/pg_ctl.conf
COPY conf/pgsrc/pg_ident.conf /etc/postgresql/11/main/pg_ident.conf

# ENV POSTGRES_USER=postgres
# ENV POSTGRES_PASSWORD=secret
# ENV POSTGRES_DB=company

# Expose PostgreSQL port
EXPOSE 5432
# EXPOSE 22

# Keep container running
CMD bash -c "service postgresql start && sleep 5 && createdb -U postgres company && psql -U postgres -h localhost -d company -f /init.sql && tail -f /dev/null"
# CMD ["sh", "-c", "service postgresql start && tail -f /dev/null"]
