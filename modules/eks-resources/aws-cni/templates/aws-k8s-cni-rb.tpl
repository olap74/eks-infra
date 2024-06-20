# Source: aws-vpc-cni/templates/clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: aws-node
  labels:
    app.kubernetes.io/name: aws-node
    app.kubernetes.io/instance: aws-vpc-cni
    k8s-app: aws-node
    app.kubernetes.io/version: "${version}"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: aws-node
subjects:
  - kind: ServiceAccount
    name: aws-node
    namespace: kube-system
