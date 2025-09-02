#!/bin/sh

# Expects the following environment variables set:
#   DESIRED_K8S_VERSION
#   TALOS_CONFIG_PATH
#   TALOS_NODES

if [ -z "$DESIRED_K8S_VERSION" ] || [ -z "$TALOS_CONFIG_PATH" ] || [ -z "$TALOS_NODES" ] ; then
  echo "Missing required environment variables."
  exit 1
fi

CURRENT_K8S_VERSION=$(talosctl --talosconfig "$TALOS_CONFIG_PATH" --nodes "$TALOS_NODES" get apiserverconfig -o yaml  | yq '.spec.image | split(":")[1] | sub("v","")')

echo Current Tag: $CURRENT_K8S_VERSION Desired Tag: $DESIRED_K8S_VERSION

if [ "$DESIRED_K8S_VERSION" = "$CURRENT_K8S_VERSION" ]; then
  echo "No Upgrade required."
else
  echo "Upgrade required."
  talosctl --talosconfig $TALOS_CONFIG_PATH --nodes "$TALOS_NODES" upgrade-k8s --to "$DESIRED_K8S_VERSION"
fi