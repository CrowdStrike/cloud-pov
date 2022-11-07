function setup_environment_variables() {
    region=$(curl -sq http://169.254.169.254/latest/meta-data/placement/availability-zone/)
    region=${region: :-1}
    accountId=$(aws sts get-caller-identity | jq -r .Account)
    #CS_CID_LOWER=$(echo $CS_CID | cut -d '-' -f 1 | tr '[:upper:]' '[:lower:]')
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

function patch_coredns(){
  printf "\nPatching CoreDNS Pods...\n"
  kubectl patch deployment coredns \
    --kubeconfig /home/ec2-user/.kube/config \
    -n kube-system \
    --type json \
    -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
  kubectl rollout restart --kubeconfig /home/ec2-user/.kube/config -n kube-system deployment coredns
}

function install_operator(){
  printf "\nInstalling Operator...\n"
  wget https://raw.githubusercontent.com/CrowdStrike/falcon-operator/main/deploy/falcon-operator.yaml -P /tmp/
  kubectl apply --kubeconfig /home/ec2-user/.kube/config -f /tmp/falcon-operator.yaml
}

function install_nodesensor(){
    cat >/tmp/node_sensor.yaml <<EOF
apiVersion: falcon.crowdstrike.com/v1alpha1
kind: FalconNodeSensor
metadata:
  name: falcon-node-sensor
spec:
  falcon_api:
    client_id: ${CS_CLIENT_ID}
    client_secret: ${CS_CLIENT_SECRET}
    cloud_region: autodiscover
  node: {}
  falcon:
    tags: 
    - cs-pov
EOF
    printf "\nInstalling Node Sensor...\n"
    kubectl apply --kubeconfig /home/ec2-user/.kube/config -f /tmp/node_sensor.yaml
}

function install_containersensor(){
    cat >/tmp/container_sensor.yaml <<EOF
apiVersion: falcon.crowdstrike.com/v1alpha1
kind: FalconContainer
metadata:
  name: falcon-container
spec:
  falcon_api:
    client_id: ${CS_CLIENT_ID}
    client_secret: ${CS_CLIENT_SECRET}
    cloud_region: autodiscover
  registry:
    type: crowdstrike
  installer_args:
    - -falconctl-opts
    - --tags=cs-pov
EOF
    printf "\nInstalling Container Sensor...\n"
    kubectl apply --kubeconfig /home/ec2-user/.kube/config -f /tmp/container_sensor.yaml
}

function install_k8s_agent(){
    cat >/tmp/k8s_agent_config.yaml <<EOF
crowdstrikeConfig:
  clientID: ${CS_CLIENT_ID}
  clientSecret: ${CS_CLIENT_SECRET}
  clusterName: ${K8S_CLUSTER_NAME}
  env: ${CS_ENV}
  cid: ${CS_CID}
  dockerAPIToken: ${DOCKER_API_TOKEN}
EOF
    printf "\nAdd kpagent Repo\n"
    helm repo add kpagent-helm https://registry.crowdstrike.com/kpagent-helm && helm repo update
    printf "\nInstalling K8S Protection Agent...\n"
    helm upgrade --install -f /tmp/k8s_agent_config.yaml --kubeconfig /home/ec2-user/.kube/config --create-namespace -n falcon-kubernetes-protection kpagent kpagent-helm/cs-k8s-protection-agent
}

function deploy_detection_container(){
    cat >/tmp/detection_container.yaml <<EOF
---
apiVersion: v1
kind: Namespace
metadata:
  name: detection-container
  labels:
    name: detection-container

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: detection-container
  namespace: detection-container
  labels:
    app: detection-container
spec:
  replicas: 1
  selector:
    matchLabels:
      app: detection-container
  template:
    metadata:
      labels:
        app: detection-container
    spec:
      containers:
      - name: detection-container
        image: quay.io/crowdstrike/detection-container
        imagePullPolicy: Always
EOF
    printf "\nDeploy Detection Container...\n"
    kubectl apply --kubeconfig /home/ec2-user/.kube/config -f /tmp/detection_container.yaml
}


setup_environment_variables
install_kubernetes_client_tools
setup_kubeconfig

if [[ $EC2_OR_FARGATE = "Fargate" ]]
then
  patch_coredns
fi

sleep 20

install_operator

if [[ $CS_SENSOR_TYPE = "FalconNodeSensor" ]]
then
  install_nodesensor
else
  install_containersensor
fi

install_k8s_agent

if [[ $DETECTION_CONTAINER = "true" ]]
then
  deploy_detection_container
fi