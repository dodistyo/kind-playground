#!/bin/bash

add_helm_charts() {
  helm repo add cilium https://helm.cilium.io/ && \
  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ && \
  helm repo add metallb https://metallb.github.io/metallb && \
  # helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/ && \
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
  helm repo add grafana https://grafana.github.io/helm-charts && \
  helm repo add cert-manager https://charts.jetstack.io && \
  helm repo add linkerd2 https://helm.linkerd.io/stable && \
  helm repo add datawire https://app.getambassador.io
}

install_cilium() {
  # Cilium
  helm install cilium cilium/cilium -f cilium/helm-values.yaml --version 1.16.5 --namespace kube-system
}

install_metrics_server() {
  # Metrics server
  helm install metrics-server metrics-server/metrics-server -f metrics-server/helm-values.yaml --version 3.12.2 -n kube-system
}

install_metallb() {
  # Metallb
  helm install metallb metallb/metallb --version 0.14.9 --create-namespace --namespace platform
}

install_external_dns() {
  # External DNS
  helm install external-dns external-dns/external-dns --version 1.15.0 -n platform --create-namespace -f external-dns/helm-values.yaml
}

install_prometheus() {
  # Prometheus
  helm install prometheus prometheus-community/prometheus -f prometheus/helm-values.yaml --version 26.1.0 --namespace monitoring --create-namespace
}

install_grafana() {
  # Grafana
  helm install grafana grafana/grafana -f grafana/helm-values.yaml --version 8.8.4 --namespace monitoring --create-namespace
}

install_cert_manager() {
  # Cert Manager
  helm install cert-manager cert-manager/cert-manager --create-namespace -n platform -f cert-manager/helm-values.yaml --version 1.16.3
}

install_linkerd() {
  # Linkerd
  helm install linkerd-crds linkerd2/linkerd-crds --version 1.8.0 && \
  helm install linkerd linkerd2/linkerd-control-plane -n linkerd --create-namespace --version 1.16.11 -f linkerd/helm-values.yaml && \
  helm install linkerd-viz linkerd2/linkerd-viz -n linkerd-viz -f linkerd-viz/helm-values.yaml --create-namespace --version 30.12.11
}

install_emissary() {
  # Emissary
  kubectl apply -f https://app.getambassador.io/yaml/emissary/3.9.1/emissary-crds.yaml && \
  kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system && \
  helm install -n platform --create-namespace emissary datawire/emissary-ingress -f emissary/helm-values.yaml --version 8.9.1
}

setup() {
  kubectl apply -k setup
}

install_all() {
  # install_cilium && \
  # install_external_dns && \
  install_metrics_server && \
  install_metallb && \
  install_prometheus && \
  install_grafana && \
  install_linkerd && \
  install_emissary && \
  install_cert_manager && \
  setup
}

case "$1" in
  add-helm-charts)
    add_helm_charts
    ;;
  cilium)
    install_cilium
    ;;
  metrics-server)
    install_metrics_server
    ;;
  metallb)
    install_metallb
    ;;
  external-dns)
    install_external_dns
    ;;
  prometheus)
    install_prometheus
    ;;
  grafana)
    install_grafana
    ;;
  cert-manager)
    install_cert_manager
    ;;
  linkerd)
    install_linkerd
    ;;
  emissary)
    install_emissary
    ;;
  setup)
    setup
    ;;
  all)
    install_all
    ;;
  *)
    echo "Usage: $0 [add-helm-charts|cilium|metrics-server|metallb|external-dns|prometheus|grafana|cert-manager|linkerd|emissary|all]"
    exit 1
    ;;
esac