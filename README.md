# oozou-exam-01

**Firstly, I designed the infrastructure or architecture of this system, which you can review  "https://drive.google.com/file/d/1FpFVDG-f0JY9zM-ZcTnfNPPKa3A_g2O7/view?usp=sharing"**

**Git structure**

/$ENV [Contains Backend, Infrastructures, and Dependencies for each environment]

/$ENV/Backend [Contains Terraform files to create S3 and Dynamo used for the backend of the Infrastructure]

/$ENV/Dependencies [Contains storageclass.yml, Helm charts of Graphite, and deployment-app-send-metrics.yml]

/.github/workflows [Contains terraform.yml for triggers to Terraform Cloud]
****

**My journey**

1. I set up Terraform Cloud with one Project and six Workspaces:
    - Projects: belieftfeks
        - Workspaces:
            - oozou-exam-01-DEV-backend
            - oozou-exam-01-DEV-infra
            - oozou-exam-01-UAT-backend
            - oozou-exam-01-UAT-infra            
            - oozou-exam-01-PRD-backend
            - oozou-exam-01-PRD-infra        

    The backend Workspace triggers the run plan in /$ENV/Backend, and the infra Workspace triggers the run plan in /$ENV/Infrastructure.

2. Terraform Files in /$ENV/Backend to create S3 bucket and DynamoDB for collecting .tfstate:
    - s3.tf contains resources "s3".
    - dynamo.tf contains resources "dynamodb_table".

    
3. Terraform Files to create VPC, EKS, EFS, and Add-ons (Module EKS Blueprints + Module EFS) in /$ENV/Infrastructure:
    - backend.tf  for referencing the backend of this Terraform.

    - 0-network.tf contains the module "vpc" to create a VPC for use in this system.

    - 1-eks.tf contains the module "eks" to create an EKS cluster and node groups for app and metrics-server via labels.

    - 2-efs.tf contains the module "clouddrove/efs/aws" to create EFS, which will be used by Graphite-server.

    - 3-addons.tf  contains the module "aws-ia/eks-blueprints-addons/aws" to deploy dependencies predefined by the module, such as:
        - argocd
        - efs-csi-driver
        - ebs-csi-driver
        - ingress-nginx

4. After applying /$ENV/Infrastructure:
    - ArgoCD: two ways to access the ArgoCD GUI
        - `kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443` and tunneling to localhost.
    
        - Change the type of service svc/argo-cd-argocd-server from Cluster-IP to LoadBalancer.

    - Get Password for access to Argocd with `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

    - esf-csi-driver: Now can use storageclass to use volumes from EFS.

5. Setup storageclass via storageclass.yml in /$ENV/Denpendencies
    ```
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
    name: efs-sc
    provisioner: efs.csi.aws.com
    parameters:
    provisioningMode: efs-ap
    fileSystemId: xxxx
    accessPointId: xxxx
    directoryPerms: "755"  # Change the permissions value to meet the minimum size requirement
    ```
    - fileSystemID:  Use the ID from the Filesystem created in the Infrastructure section.
    - accessPointID: Use the ID from the Access Point in the Filesystem.

6. Prepared Helm Charts to deploy Graphite in /$ENV/Dependencies/helm with the command `helm install`.
    - I configured values.yaml to use PVC for claiming volumes from EFS by referencing a storage class.
    - I configured values.yaml to create a LoadBalancer service type and append NodePort to all ports of Graphite.
    - I configured templates/deployment.yaml, templates/service.yaml, and templates/pvc.yml to use variables from values.yaml.

7. I change endpoints in index.js from localhost to service of graphite
    `const metrics = new lynx('graphite-server-graphite-server-dev.default.svc.cluster.local', 8125);`
    After that, I build and push to `thamkrabok/app-send-metrics:1.0.0`

8. I have prepared deployment-app-send-metrics.yml in /$ENV/Dependencies for deploy app with command `kubectl apply -f deployment-app-send-metrics.yml`
