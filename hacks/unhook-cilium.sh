#!/bin/bash

set -x

KUBECONFIG=kubeconfig

attachments=$(kubectl -n cilium exec ds/cilium -- bpftool cgroup list /run/cilium/cgroupv2  | tail -n +2 | awk '{print $2 " id " $1 }')

echo "${attachments}" | 
while IFS= read -r args; do
    kubectl -n cilium exec ds/cilium -- bpftool cgroup detach /run/cilium/cgroupv2 ${args}
done 