#!/bin/bash

flag=$1

## Functions

checkRequirements() {
    
    #Checking if all requrements are filled and ssh keys exist

    if [ -z $jenkins_username ]     || \
       [ -z $jenkins_password ]     || \
       [ -z $aws_access_key_id ]    || \
       [ -z $aws_secret_access_key ]|| \
       [ -z $dns_zone_id ]          || \
       [ -z $nexus_password ]       || \
       [ -z $sql_password ]       || \
       [ ! -f $public_ssh_key_path ]|| \
       [ ! -f $ssh_key_path ]; then
            echo "Correct data in requirements.txt file"
            exit
          
    fi
}

collectData (){
    jenkins_username=$(     grep jenkins_username requirements.txt       | cut -d : -f2)
    jenkins_password=$(     grep jenkins_password requirements.txt       | cut -d : -f2)
    public_ssh_key_path=$(  grep public_ssh_key_path requirements.txt    | cut -d : -f2)
    ssh_key_path=$(         grep ^ssh_key_path requirements.txt          | cut -d : -f2)
    aws_access_key_id=$(    grep aws_access_key_id requirements.txt      | cut -d : -f2)
    aws_secret_access_key=$(grep aws_secret_access_key requirements.txt  | cut -d : -f2)
    dns_zone_id=$(          grep dns_zone_id requirements.txt            | cut -d : -f2)
    nexus_password=$(       grep nexus_password requirements.txt         | cut -d : -f2)
    sql_password=$(       grep sql_password requirements.txt         | cut -d : -f2)

    echo -n $nexus_password > nexus/admin.password
}

##  infrastracture 

terraformApply () {

    cd terraform  && \
    terraform init && \
    terraform apply     -var="ssh_key_path=$public_ssh_key_path" \
                        -var="dns_zone_id=$dns_zone_id" \
                        -var="sql_password=$sql_password" \
                        -auto-approve  && \
    instance_id=$(      terraform output instance_id      | tr -d '"') && \
    instance_ip_addr=$( terraform output instance_ip_addr | tr -d '"') && \
    sql_host=$(         terraform output db_address       | tr -d '"') && \
    aws ec2 wait instance-status-ok \
                --instance-ids $instance_id && \
    echo "Infra is running with no errors." && \
    cd ../

}


configureOpsServer() {
    cd ansible && \
    ansible-playbook install_docker.yml     -e ansible_host=$instance_ip_addr -e ansible_ssh_private_key_file=$ssh_key_path && \
    ansible-playbook install_wireguard.yml  -e ansible_host=$instance_ip_addr && \
    ansible-playbook install_nexus.yml      -e ansible_host=$instance_ip_addr && \
    ansible-playbook install_nginx.yml      -e ansible_host=$instance_ip_addr && \
    ansible-playbook install_jenkins.yml    -e ansible_host=$instance_ip_addr \
                                            -e username=$jenkins_username \
                                            -e password=$jenkins_password  \
                                            -e nexus_password=$nexus_password \
                                            -e sql_host=$sql_host \
                                            -e sql_password=$sql_password \
                                            -e aws_access_key_id=$aws_access_key_id \
                                            -e aws_secret_access_key=$aws_secret_access_key && \ 
    ansible-playbook install_monitoring.yml -e ansible_host=$instance_ip_addr && \
    cd ../
}

printHelp() {
    echo """ 
!!! CHECK the requirements.txt file !!!
change the values before you run the script

Check if you have Docker, Ansible, Terraform, AWS cli 
installed and configured in your machine and they are working correctly


Run with --erase flag to delete all resources which was created
    """
}



eraseAll() {
    cd terraform && \
    terraform destroy -auto-approve
}




# Checking flags and running

if [[ $flag = '--erase' ]]; then
    eraseAll
elif [[ $flag = "--help" ]]; then
    printHelp
elif [[ -z $flag ]]; then 
    
    collectData && \
    checkRequirements && \
    terraformApply && \
    configureOpsServer
fi

