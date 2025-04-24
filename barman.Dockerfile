FROM postdock/barman:latest

# Install SSH client
# RUN apt-get update && apt-get install -y openssh-client
# RUN service ssh start
# Create .ssh directory
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Add SSH keys
COPY keys/id_rsa /root/.ssh/id_rsa
COPY keys/id_rsa.pub /root/.ssh/id_rsa.pub

# Set proper permissions for SSH keys
RUN chmod 600 /root/.ssh/id_rsa && \
    chmod 644 /root/.ssh/id_rsa.pub

# Create .ssh directory
RUN mkdir -p /var/lib/barman/.ssh && chmod 700 /var/lib/barman/.ssh

# Add SSH keys
COPY keys/id_rsa /var/lib/barman/.ssh/id_rsa
COPY keys/id_rsa.pub /var/lib/barman/.ssh/id_rsa.pub

# Set proper permissions for SSH keys
RUN chmod 600 /var/lib/barman/.ssh/id_rsa && \
    chmod 644 /var/lib/barman/.ssh/id_rsa.pub


#Copy pg.conf file to barman.d folder
COPY  barman/pg.conf /etc/barman.d/pg.conf


# Generate known_hosts file if needed
# RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

# Your additional setup commands here
# ...

# CMD ["/bin/bash"]
# CMD bash -c "service ssh start"