# README

## Overview

This repository contains an Ansible playbook and a Docker-based Ubuntu systemd environment for testing log rotation of a custom service (`custom-monitor.service`). All commands run from rpository root folder.

---

# Local testing
## 1. Generate SSH keys

```bash
ssh-keygen -t rsa -b 4096 -f ./assets/sre-logrotate-0
chmod 400 ./assets/sre-logrotate-0
chmod 400 ./assets/sre-logrotate-0.pub
```

## 2. Build the Docker image
```bash
docker build -t ubuntu-systemd-sshd .
```

## 3. Run the container
```bash
docker run --privileged \
  -d \
  --name sre-log-rotate \
  --hostname sre-log-rotate \
  -p 2222:22 \
  ubuntu-systemd-sshd
```

## 4. SSH into the container for testing
```bash
ssh ubuntu@localhost -p 2222 -i ./assets/sre-logrotate-0
```

## 5. Test Ansible connectivity and run playbook
```bash
ansible sre-log-rotate-local -i inventory.yml -m ping
ansible-playbook -i inventory.yml logrotate.yml --limit sre-log-rotate-local
```

## 6. Verify results inside the container
```bash
ls -l /var/log/custom-monitor
cat /etc/logrotate.d/custom-monitor
systemctl status custom-monitor.service
```

## 7. Test log rotation
```bash
sudo bash -c 'seq 1 10000 > /var/log/custom-monitor/monitor.log'
ls -lh /var/log/custom-monitor

sudo logrotate -f /etc/logrotate.d/custom-monitor
ls -lh /var/log/custom-monitor
```

## 8. Cleanup
```bash
docker rm -f sre-log-rotate
```

# Remote test

## 1. Download ssh key
```bash
# Downdload ssh key to ~/.ssh/sre-logrotate-0.pem
chmod 600 ~/.ssh/sre-logrotate-0.pem
```

## 2. ssh login for testing 
```bash
ssh ubuntu@3.99.166.138 -p 22 -i ~/.ssh/sre-logrotate-0.pem
```

## 4. Ansible run 
```bash
ansible sre-log-rotate -i inventory.yml -m ping
ansible-playbook -i inventory.yml logrotate.yml --limit sre-log-rotate
```

## 5. Test log rotation
```bash
ls -lh /var/log/custom-monitor
systemctl status custom-monitor.service
sudo logrotate -d /etc/logrotate.d/custom-monitor
sudo logrotate -f /etc/logrotate.d/custom-monitor
ls -lh /var/log/custom-monitor
systemctl status custom-monitor.service
```