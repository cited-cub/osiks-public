#! /bin/bash
#coredns_patch.yaml
kubectl -n kube-system patch cm coredns --patch-file ./coredns_patch.yaml -o json
