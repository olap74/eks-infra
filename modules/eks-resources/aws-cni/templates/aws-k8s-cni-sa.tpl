# Source: aws-vpc-cni/templates/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aws-node
  namespace: kube-system
  labels:
    app.kubernetes.io/name: aws-node
    app.kubernetes.io/instance: aws-vpc-cni
    k8s-app: aws-node
    app.kubernetes.io/version: "${version}"
