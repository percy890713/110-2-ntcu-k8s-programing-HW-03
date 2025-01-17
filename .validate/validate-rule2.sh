#!/bin/bash

echo ""
echo "驗證初始無Service"


# 初始應無svc
LABEL="ntcu-k8s=hw3"
svc_num=`kubectl get svc   -l ${LABEL}  -o yaml | yq '.items | length'`


if [[ "$svc_num" -ne 0 ]]; then
    echo "informer建立的svc數量 $svc_num 不正確. 應為 0"
    exit 1
fi

# 建立隨機nginx deployment
deployment=nginx-deployment
random=`echo ${RANDOM}`

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${deployment}
  labels:
    name: nginx
    ntcu-k8s: hw3
spec:
  replicas: 1
  selector:
    matchLabels:
      name: nginx-${random}
  template:
    metadata:
      labels:
        name: nginx-${random}
    spec:
      containers:
        - name: nginx
          image: nginx:1.7.9
          ports:
            - containerPort: 80
EOF

# 等待nginx ready

ready="false"
for i in {1..60}; do
  ready=`kubectl get deployments.apps ${deployment} >/dev/null  2>&1  && kubectl get deployments.apps ${deployment} -o yaml |  yq .status.readyReplicas==.status.replicas`

	if [ "$ready" == "true" ]; then
		echo "........ PASS"
    exit 0
	fi
  sleep 2
done

echo "timeout 120 sec. wait for create deployment ${deployment} success"
exit 1