# some helper script to get infra started

# set up cluster
kind create cluster --name=tfx-kubeflow-cluster --config=kind-config.yaml

# deploy kubeflow pipeline
# https://www.kubeflow.org/docs/components/pipelines/installation/localcluster-deployment/
export PIPELINE_VERSION=1.7.0
kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"
kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/env/platform-agnostic-pns?ref=$PIPELINE_VERSION"

# deploy pv
k apply -f tfx-pv.yaml

# patch kubeflow ui deployment
kubectl patch deployment ml-pipeline-ui --patch "$(cat patch-ml-pipeline-ui.yaml)" -n kubeflow --type strategic

# Create secret
kubectl create secret -n kubeflow generic gcs-pipeline-output-sa --from-file=gcs-pipeline-output-sa.json=tfx-e2e-70e117e15758.json

# delete kubeflow pipeline
# export PIPELINE_VERSION=1.7.0
# kubectl delete -k "github.com/kubeflow/pipelines/manifests/kustomize/env/platform-agnostic-pns?ref=$PIPELINE_VERSION"
# kubectl delete -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"
