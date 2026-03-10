FROM debian:trixie

# Install SSH and Python for Ansible
RUN apt-get update && apt-get install -y \
    openssh-server \
    python3 \
    python3-apt \
    sudo \
    systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure SSH
RUN mkdir -p /var/run/sshd /root/.ssh && \
    chmod 700 /root/.ssh

# Copy dev SSH key
COPY .ssh/dev_key.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Configure sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

EXPOSE 22

# Start SSH
CMD ["/usr/sbin/sshd", "-D"]
