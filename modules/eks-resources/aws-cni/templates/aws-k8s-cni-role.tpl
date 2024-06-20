# Source: aws-vpc-cni/templates/clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: aws-node
  labels:
    app.kubernetes.io/name: aws-node
    app.kubernetes.io/instance: aws-vpc-cni
    k8s-app: aws-node
    app.kubernetes.io/version: "${version}"
rules:
  - apiGroups:
      - crd.k8s.amazonaws.com
    resources:
      - eniconfigs
    verbs: ["list", "watch", "get"]
  - apiGroups: [""]
    resources:
      - namespaces
    verbs: ["list", "watch", "get"]
  - apiGroups: [""]
    resources:
      - pods
    verbs: ["list", "watch", "get"]        
  - apiGroups: [""]
    resources:
      - nodes
    verbs: ["list", "watch", "get", "update"]
  - apiGroups: ["extensions"]
    resources:
      - '*'
    verbs: ["list", "watch"]
