# Dockerfile for kubearchinspect
# Arm Developer Ecosystem - https://github.com/ArmDeveloperEcosystem/kubearchinspect
#
# Build and push to ECR:
#
#   VERSION=0.7.0
#   REPO=336151728602.dkr.ecr.us-east-1.amazonaws.com/kubearchinspect
#
#   aws ecr create-repository --repository-name kubearchinspect --region us-east-1
#
#   docker buildx build \
#     --platform linux/arm64 \
#     --build-arg VERSION=${VERSION} \
#     -t ${REPO}:${VERSION} \
#     -t ${REPO}:latest \
#     --push .

ARG VERSION=0.7.0

# --- Download stage ---
FROM alpine:3.19 AS downloader
ARG VERSION
ARG TARGETOS=linux
ARG TARGETARCH=arm64

RUN apk add --no-cache wget tar ca-certificates

RUN wget -qO /tmp/kubearchinspect.tar.gz \
    "https://github.com/ArmDeveloperEcosystem/kubearchinspect/releases/download/v${VERSION}/kubearchinspect_${TARGETOS^}_${TARGETARCH}.tar.gz" \
    && tar xz -f /tmp/kubearchinspect.tar.gz -C /tmp/ \
    && chmod +x /tmp/kubearchinspect

# --- Final stage ---
FROM alpine:3.19
ARG VERSION

RUN apk add --no-cache ca-certificates \
    && addgroup -S kubearchinspect \
    && adduser -S -G kubearchinspect kubearchinspect

COPY --from=downloader /tmp/kubearchinspect /usr/local/bin/kubearchinspect

USER kubearchinspect

LABEL org.opencontainers.image.title="kubearchinspect" \
      org.opencontainers.image.description="Check if container images in a Kubernetes cluster have arm64 architecture support" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/ArmDeveloperEcosystem/kubearchinspect"

ENTRYPOINT ["kubearchinspect"]
