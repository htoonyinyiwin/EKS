#!/bin/bash
set -e

ACCOUNT_ID="298225145086"
REGION="ap-northeast-1"
ECR="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

echo "Logging in to ECR..."
aws ecr get-login-password --region ${REGION} --profile github-eks | \
  docker login --username AWS --password-stdin ${ECR}

mirror() {
  local src=$1
  local dest=$2
  echo "Mirroring ${src} → ${dest}"
  docker pull ${src}
  docker tag ${src} ${dest}
  docker push ${dest}
}

mirror \
  quay.io/argoproj/argocd:v2.14.10 \
  ${ECR}/argocd:v2.14.10

mirror \
  ghcr.io/dexidp/dex:v2.42.1 \
  ${ECR}/dex:v2.42.1

mirror \
  public.ecr.aws/docker/library/redis:7.4.2-alpine \
  ${ECR}/redis:7.4.2-alpine

echo "Done. Images available in ECR."
