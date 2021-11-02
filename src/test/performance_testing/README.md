# Agent affinity

to schedule `55` agents to the same node we use affinity. The node is first labelled i.e.

```yaml
kubectl label --overwrite=true node ip-192-168-80-11.eu-central-1.compute.internal  eks.amazonaws.com/nodegroup=agent
```

and then we update the addinity in the agent `values.yaml` with


```yaml
# -- Standard K8s affinities that will be applied to all Bamboo agent pods
#
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: eks.amazonaws.com/nodegroup
              operator: In
              values:
                - agent
```
