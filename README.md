# Description
Terrafrom, Ansible scripts to deploy Nginx, serving helloWorld index.html originally stored in S3 bucket.
## Requirements 
* Target server OS - Ubuntu 18.04, 16.04
* Use Ansible 2.7 version minimum
* Use Terrafrom v0.12.6 version minimum
* Configuration variables can be changed in files:
  ```shell
  ./variables.tf
  install-web-server.yaml
  ```
