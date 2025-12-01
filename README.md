# README

## Overview

This repository contains an Ansible playbook and a Docker-based Ubuntu systemd environment for testing log rotation of a custom service (`custom-monitor.service`). All commands run from rpository root folder.

---

## 1. Generate SSH keys

```bash
ssh-keygen -t rsa -b 4096 -f ./assets/sre-logrotate-0
chmod 400 ./assets/sre-logrotate-0
chmod 400 ./assets/sre-logrotate-0.pub
```

## 2. Build the Docker image
```
docker build -t ubuntu-systemd-sshd .
```

## 3. Run the container
```
docker run --privileged \
  -d \
  --name sre-log-rotate \
  --hostname sre-log-rotate \
  -p 2222:22 \
  ubuntu-systemd-sshd
```

## 4. SSH into the container for testing
```
ssh ubuntu@localhost -p 2222 -i ./assets/sre-logrotate-0
```

## 5. Test Ansible connectivity and run playbook
```
ansible sre-log-rotate -m ping
ansible-playbook playbook.yml
```

## 6. Verify results inside the container
```
ls -l /var/log/custom-monitor
cat /etc/logrotate.d/custom-monitor
systemctl status custom-monitor.service
```

## 7. Test log rotation
```
sudo bash -c 'seq 1 10000 > /var/log/custom-monitor/monitor.log'
ls -lh /var/log/custom-monitor

sudo logrotate -f /etc/logrotate.d/custom-monitor
ls -lh /var/log/custom-monitor
```

## Cleanup
```
docker rm -f sre-log-rotate
```