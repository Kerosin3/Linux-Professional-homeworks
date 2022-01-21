#!/bin/bash
ansible all -m ping
ssh-keygen -b 2048 -t rsa -f /tmp/sshkey -q -N ""
