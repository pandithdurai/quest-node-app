# Deploy node.js webapp in to GKE

### Containerizing Quest Node.js Web App

Prerequisites:

1. Docker installed and running on the system.
2. Quest Node.js project with web application code.

Steps:

1. create directry quest-node-app and initialize git repo

        mkdir quest-node-app && git init

2. create node-app-gcp directory and add node.js application code from https://github.com/rearc/quest/tree/master

        mkdir node-app-gcp

3. Create a file named Dockerfile in the root directory of Node.js project and define the instructions in Dockerfile

        touch Dockerfile

4. Build the docker image

        docker build -t my-node-app .
    
5. Run the conatiner locally and naviagate http://localhost:3000 to see if app works

        docker run -p 3000:3000 my-node-app

### Push docker image to Google Artifcat Registry(GAR)

1. Create GAR repo

        gcloud artifacts repositories create rearc-quest --repository-format=docker --location us-central1

2. Pushing a local image to GAR

        gcloud auth configure-docker us-central1-docker.pkg.dev &&
        docker tag my-node-app us-central1-docker.pkg.dev/quest-demo-438215/rearc-quest/rearc-quest-node-app:latest &&
        docker push us-central1-docker.pkg.dev/quest-demo-438215/rearc-quest/rearc-quest-node-app


### Deploy quest node.js docker image to Google Kubernetes Engine(GKE)

Naviage to terraform directory and run terraform commands

        cd terraform
        terraform init
        terraform plan
        terraform apply

The terraform deployment will create the following components in GCP

    1. GCP Network
    2. GCP Subnetwork
    3. GKE Autopilot cluster
    4. Kubernetes Secret
    4. Kuberntetes Deployment
    5. Kubernetes Service
    6. Kubernetes Ingress

After successful deployment of all the components, we can access the quest node.js app using GCP external Application load balancer IP

1. Naviagate to GCP console https://console.cloud.google.com/kubernetes/list/overview?authuser=0&project=quest-demo-438215
2. Choose Gateways, Services & Ingress in the left pane
3. Choose Ingress and click the link under Frontend
4. The quest node.js app will open in browser.