# AnsibleSample

# Require

+ Docker
+ Ansible
+ Serverspec(Option)

# Setup

```bash
$ssh-keygen
$cp ~/.ssh/rsa_id.pub authorized_keys
$docker build -t docker/ansible
$bundle install
```

# ansible.sh

Run docker for ansible

```bash
$./ansible.sh prepare
```
Run ansible

```bash
$./ansible.sh run all.yml
```

Run serverspec(maintenance)

```bash
$./ansible.sh test
```

Stop and rm docker

```bash
$./ansible.sh delete
```
