FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y systemd systemd-sysv openssh-server logrotate python3 sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# sshd setup
RUN mkdir -p /var/run/sshd

# add ubuntu user
RUN useradd -m -s /bin/bash ubuntu && \
    echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu && \
    chmod 440 /etc/sudoers.d/ubuntu

# put ssh key with proper perissions
RUN mkdir -p /home/ubuntu/.ssh && chmod 700 /home/ubuntu/.ssh
COPY assets/sre-logrotate-0.pub /home/ubuntu/.ssh/authorized_keys
RUN chmod 600 /home/ubuntu/.ssh/authorized_keys && \
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# disable password auth for security 
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# add dummy custom-monitor.service
COPY assets/custom-monitor.service /etc/systemd/system/custom-monitor.service
RUN systemctl enable custom-monitor.service || true

# run systemd on start
CMD ["/sbin/init"]
