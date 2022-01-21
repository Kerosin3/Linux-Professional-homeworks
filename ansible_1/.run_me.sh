#/bin/bash
vagrant destroy -f && vagrant up
ansible-playbook ./playbooks/servers.yml -f 10
