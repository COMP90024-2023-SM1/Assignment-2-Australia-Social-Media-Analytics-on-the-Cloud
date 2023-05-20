# Ansible
## Requirements
1. Download your own `openrc.sh` from the MRC website, put it under the current directory (`unimelb-comp90024-2023-grp-64-openrc.sh` in our case).

2. Generate a password from MRC (click reset password) for OpenStack API access.

3. Install `ansible`.
    - For MacOS: 
    ``` 
    brew install ansible
    ```
    - For Linux (Ubuntu): 
    ```
    sudo apt update
    sudo apt install ansible
    ```

4. Run `run-mrc.sh` to run the Ansible playbook (create MRC instances and setup Couchdb).

  ```
  chmod 600 run-mrc.sh
  ./run-mrc.sh
  ```