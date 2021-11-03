#!/bin/sh

nuke_running_deployments() {
  echo "Uninstall helm deployments...."
  helm uninstall postgres-db
  helm uninstall bamboo
  kubectl delete pvc local-home-bamboo-0
}

clean_shared_home() {
  echo "Clean up shared home..."
  kubectl exec shared-home-browser -- rm -rf /shared-home/artifacts
  kubectl exec shared-home-browser -- rm -rf /shared-home/attachments
  kubectl exec shared-home-browser -- rm -rf /shared-home/backups
  kubectl exec shared-home-browser -- rm -rf /shared-home/builds
  kubectl exec shared-home-browser -- rm -rf /shared-home/configuration
  kubectl exec shared-home-browser -- rm -rf /shared-home/index
  kubectl exec shared-home-browser -- rm -rf /shared-home/jms-store
  kubectl exec shared-home-browser -- rm -rf /shared-home/plugins
  kubectl exec shared-home-browser -- rm -rf /shared-home/serverState
  kubectl exec shared-home-browser -- rm -rf /shared-home/temp
  kubectl exec shared-home-browser -- rm -rf /shared-home/templates
}

provision_db() {
  echo "Provision Postgres..."
  helm install -n "bamboo" --wait  "postgres-db" --values "./src/test/infrastructure/postgres/postgres-values.yaml"  --set fullnameOverride="postgres-db" --set image.tag="12" --set postgresqlDatabase="bamboo" --set postgresqlUsername="postgres" --set postgresqlPassword="postgres" --version "9.4.1" bitnami/postgresql
  kubectl delete secrets postgres-db
  kubectl create secret generic postgres-db --from-literal=username=postgres --from-literal=password=postgres
}

deploy_bamboo() {
  echo "Deploy Bamboo..."
  helm install bamboo --values src/main/charts/bamboo/values.yaml src/main/charts/bamboo
}

add_dataset() {
  sleep 30
  echo "Adding dataset..."
  kubectl exec bamboo-0 -- apt update
  kubectl exec bamboo-0 -- apt install wget
  kubectl exec bamboo-0 -- wget https://centaurus-datasets.s3.us-east-2.amazonaws.com/bamboo/dcapt_bamboo.zip
}

nuke_running_deployments
#clean_shared_home
provision_db
deploy_bamboo
#add_dataset
