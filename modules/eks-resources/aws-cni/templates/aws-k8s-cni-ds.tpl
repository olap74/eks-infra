# Source: aws-vpc-cni/templates/daemonset.yaml
kind: DaemonSet
apiVersion: apps/v1
metadata:
  name: aws-node
  namespace: kube-system
  labels:
    app.kubernetes.io/name: aws-node
    app.kubernetes.io/instance: aws-vpc-cni
    k8s-app: aws-node
    app.kubernetes.io/version: "${version}"
spec:
  updateStrategy:
    rollingUpdate:
      maxUnavailable: 10%
    type: RollingUpdate
  selector:
    matchLabels:
      k8s-app: aws-node
  template:
    metadata:
      labels:
        app.kubernetes.io/name: aws-node
        app.kubernetes.io/instance: aws-vpc-cni
        k8s-app: aws-node
    spec:
      priorityClassName: "system-node-critical"
      serviceAccountName: aws-node
      hostNetwork: true
      initContainers:
      - name: aws-vpc-cni-init
        image: "${source_account}.dkr.ecr.${region}.amazonaws.com/amazon-k8s-cni-init:${version}"
        env:
          - name: DISABLE_TCP_EARLY_DEMUX
            value: "false"
          - name: ENABLE_IPv6
            value: "false"
        securityContext:
            privileged: true
        volumeMounts:
          - mountPath: /host/opt/cni/bin
            name: cni-bin-dir
      terminationGracePeriodSeconds: 10
      tolerations:
        - operator: Exists
      securityContext:
        {}
      containers:
        - name: aws-node
          image: "${source_account}.dkr.ecr.${region}.amazonaws.com/amazon-k8s-cni:${version}"
          ports:
            - containerPort: 61678
              name: metrics
          livenessProbe:
            exec:
              command:
              - /app/grpc-health-probe
              - -addr=:50051
              - -connect-timeout=5s
              - -rpc-timeout=5s
            initialDelaySeconds: 60
            timeoutSeconds: 10
          readinessProbe:
            exec:
              command:
              - /app/grpc-health-probe
              - -addr=:50051
              - -connect-timeout=5s
              - -rpc-timeout=5s
            initialDelaySeconds: 1
            timeoutSeconds: 10
          env:
            - name: ADDITIONAL_ENI_TAGS
              value: "{}"
            - name: AWS_VPC_CNI_NODE_PORT_SUPPORT
              value: "true"
            - name: AWS_VPC_ENI_MTU
              value: "9001"
            - name: AWS_VPC_K8S_CNI_CONFIGURE_RPFILTER
              value: "false"
            - name: AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG
              value: "false"
            - name: AWS_VPC_K8S_CNI_EXTERNALSNAT
              value: "false"
            - name: AWS_VPC_K8S_CNI_LOGLEVEL
              value: "DEBUG"
            - name: AWS_VPC_K8S_CNI_LOG_FILE
              value: "/host/var/log/aws-routed-eni/ipamd.log"
            - name: AWS_VPC_K8S_CNI_RANDOMIZESNAT
              value: "prng"
            - name: AWS_VPC_K8S_CNI_VETHPREFIX
              value: "eni"
            - name: AWS_VPC_K8S_PLUGIN_LOG_FILE
              value: "/var/log/aws-routed-eni/plugin.log"
            - name: AWS_VPC_K8S_PLUGIN_LOG_LEVEL
              value: "DEBUG"
            - name: DISABLE_INTROSPECTION
              value: "false"
            - name: DISABLE_METRICS
              value: "false"
            - name: DISABLE_NETWORK_RESOURCE_PROVISIONING
              value: "false"
            - name: ENABLE_IPv4
              value: "true"
            - name: ENABLE_IPv6
              value: "false"
            - name: ENABLE_POD_ENI
              value: "false"
            - name: ENABLE_PREFIX_DELEGATION
              value: "false"
            - name: WARM_IP_TARGET
              value: "3"
            - name: WARM_PREFIX_TARGET
              value: "1"
            - name: MY_NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
          resources:
            requests:
              cpu: 10m
          securityContext:
            capabilities:
              add:
              - NET_ADMIN
          volumeMounts:
          - mountPath: /host/opt/cni/bin
            name: cni-bin-dir
          - mountPath: /host/etc/cni/net.d
            name: cni-net-dir
          - mountPath: /host/var/log/aws-routed-eni
            name: log-dir
          - mountPath: /var/run/dockershim.sock
            name: dockershim
          - mountPath: /var/run/aws-node
            name: run-dir
          - mountPath: /run/xtables.lock
            name: xtables-lock
      volumes:
      - name: cni-bin-dir
        hostPath:
          path: /opt/cni/bin
      - name: cni-net-dir
        hostPath:
          path: /etc/cni/net.d
      - name: dockershim
        hostPath:
          path: /var/run/dockershim.sock
      - name: log-dir
        hostPath:
          path: /var/log/aws-routed-eni
          type: DirectoryOrCreate
      - name: run-dir
        hostPath:
          path: /var/run/aws-node
          type: DirectoryOrCreate
      - name: xtables-lock
        hostPath:
          path: /run/xtables.lock
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                - linux
              - key: kubernetes.io/arch
                operator: In
                values:
                - amd64
                - arm64
              - key: eks.amazonaws.com/compute-type
                operator: NotIn
                values:
                - fargate
