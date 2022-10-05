function setup_environment_variables() {
    region=$(curl -sq http://169.254.169.254/latest/meta-data/placement/availability-zone/)
    region=${region: :-1}
    accountId=$(aws sts get-caller-identity | jq -r .Account)
}

function install_kubernetes_client_tools() {
    printf "\nInstall K8s Client Tools"
    mkdir -p /usr/local/bin/
    curl --retry 5 -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/
    mkdir -p /root/bin
    ln -s /usr/local/bin/kubectl /root/bin/
    ln -s /usr/local/bin/kubectl /opt/aws/bin
    cat > /etc/profile.d/kubectl.sh <<EOF
#!/bin/bash
source <(/usr/local/bin/kubectl completion bash)
EOF
    chmod +x /etc/profile.d/kubectl.sh
    curl --retry 5 -o helm.tar.gz https://get.helm.sh/helm-v3.3.4-linux-amd64.tar.gz
    tar -xvf helm.tar.gz
    chmod +x ./linux-amd64/helm
    mv ./linux-amd64/helm /usr/local/bin/helm
    ln -s /usr/local/bin/helm /opt/aws/bin
    rm -rf ./linux-amd64/
}

function setup_kubeconfig() {
    clusterArn="arn:aws:eks:$region:$accountId:cluster/$K8S_CLUSTER_NAME"
    mkdir -p /home/ec2-user/.kube
    source /root/.bashrc
    cat > /home/ec2-user/.kube/config <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${K8S_CA_DATA}
    server: ${K8S_ENDPOINT}
  name: ${clusterArn}
contexts:
- context:
    cluster: ${clusterArn}
    user: ${clusterArn}
  name: ${clusterArn}
current-context: ${clusterArn}
kind: Config
preferences: {}
users:
- name: ${clusterArn}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - --region
        - ${region}
        - eks
        - get-token
        - --cluster-name
        - ${K8S_CLUSTER_NAME}
        # - "- --role-arn"
        # - "arn:aws:iam::$accountId:role/my-role"
      # env:
        # - name: "AWS_PROFILE"
        #   value: "aws-profile"
EOF
    printf "\nKube Config:\n"
    cat /home/ec2-user/.kube/config
    mkdir -p /root/.kube/
    cp /home/ec2-user/.kube/config /root/.kube/
    chown -R ec2-user:${user_group} /home/ec2-user/.kube/
    # Add SSM Config for ssm-user
    /sbin/useradd -d /home/ssm-user -u 1001 -s /bin/bash -m --user-group ssm-user
    mkdir -p /home/ssm-user/.kube/
    cp /home/ec2-user/.kube/config /home/ssm-user/.kube/config
    chown -R ssm-user:ssm-user /home/ssm-user/.kube/
}

setup_environment_variables
install_kubernetes_client_tools
setup_kubeconfig