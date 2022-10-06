# DevOps project for djangoproject.com

This is my project created at DevOps Bootcamp I was participating.

This is the website source code which I use    https://github.com/atyanh/django


Tools I used `

 - Terraform
 - Ansible
 - Docker
 - Kubernetes
 - Jenkins 
 - Nginx
 - Nexus
 - Promoetheus + Grafana
 - Wireguard VPN

## Infrastructure

I deploy my Infrastructure on AWS Cloud via Terraform.


![](https://i.imgur.com/2Pe4S8T.png)


## Ops Server

Ansible playbooks will install Docker, Jenkins, Nexus, Nginx, Wireguard VPN
and Prometheus with Grafana on Ops server.

I automated Jenkins deployment, so after running on server the CI/CD pipeline job
will already work.

I automated Nexus deployment, so the Docker repository will be created already.

I use letsencrypt on Nginx certificate to provide HTTPS for docker registry.

