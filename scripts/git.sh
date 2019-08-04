#!/usr/bin/env bash

set -e

SSH_PATH=/home/go/.ssh
SCM="${1?You must specify a SCM, eg: github.com}"

generate_ssh_directory() {
  mkdir -p $SSH_PATH
}

scan_public_ssh_key() {
  ssh-keyscan $SCM > $SSH_PATH/known_hosts
}

generate_ssh_key() {
  ssh-keygen -t rsa -f $SSH_PATH/id_rsa -q -P ""
}

print_public_ssh_key() {
  echo -e "\e[93m\e[5mCOPY SSH PUBLIC KEY BELOW\e[0m"
  cat $SSH_PATH/id_rsa.pub
}

check_installed_key_loop() {
  ssh -T git@$SCM &> /dev/null
}

check_installed_key() {
  printf '\e[31m%s\e[0m' "Testing SSH key"

  while true; do
    check_installed_key_loop || {
      if [[ "$?" -eq 1 ]]; then
        break
      fi
    }

    printf '\e[31m%s\e[0m' "."
    sleep 3
  done

  echo -e "\n\e[31mKey successfully installed.\e[0m"
}

generate_ssh_directory
scan_public_ssh_key
generate_ssh_key
print_public_ssh_key
check_installed_key

