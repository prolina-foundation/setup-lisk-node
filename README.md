# Setup a Lisk node on Ubuntu 18.04 using Ansible

1. Create a fresh Ubuntu 18.04 LTS installation and ensure you can SSH to it using Public-key
2. Upgrade all installed packages
3. Change host and user to your configuration in `hosts.txt`
4. Run `ansible-playbook site.yml -i hosts.txt --ask-become-pass`

Lisk should now be running and syncing. Check status on the remote machine:

```
$ cd /workspace/lisk
$ ./lisk.sh logs
```
