---
title: grafana-agent
---

## Overview



{{< panel style="danger" >}}
Jsonnet source code is available at [github.com/grafana/agent.git](https://github.com/grafana/agent.git/tree/master/operations/agent-flow-mixin)
{{< /panel >}}

## Alerts

{{< panel style="warning" >}}
Complete list of pregenerated alerts is available [here](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/alerts.yaml).
{{< /panel >}}

### clustering

##### ClusterNotConverging

{{< code lang="yaml" >}}
alert: ClusterNotConverging
annotations:
  message: Cluster is not converging.
expr: stddev by (cluster, namespace) (sum without (state) (cluster_node_peers)) != 0
for: 5m
{{< /code >}}
 
##### ClusterSplitBrain

{{< code lang="yaml" >}}
alert: ClusterSplitBrain
annotations:
  message: Cluster nodes have entered a split brain state.
expr: |
  sum without (state) (cluster_node_peers) !=
  on (cluster, namespace) group_left
  count by (cluster, namespace) (cluster_node_info)
for: 5m
{{< /code >}}
 
##### ClusterLamportClockDrift

{{< code lang="yaml" >}}
alert: ClusterLamportClockDrift
annotations:
  message: Cluster nodes' lamport clocks are not converging.
expr: stddev by (cluster, namespace) (cluster_node_lamport_time) > 4 * sqrt(count by (cluster, namespace) (cluster_node_info))
for: 5m
{{< /code >}}
 
##### ClusterNodeUnhealthy

{{< code lang="yaml" >}}
alert: ClusterNodeUnhealthy
annotations:
  message: Cluster node is reporting a health score > 0.
expr: |
  cluster_node_gossip_health_score > 0
for: 5m
{{< /code >}}
 
##### ClusterLamportClockStuck

{{< code lang="yaml" >}}
alert: ClusterLamportClockStuck
annotations:
  message: Cluster nodes's lamport clocks is not progressing.
expr: |
  sum by (cluster, namespace, instance) (rate(cluster_node_lamport_time[2m])) == 0
  and on (cluster, namespace, instance) (cluster_node_peers > 1)
for: 5m
{{< /code >}}
 
##### ClusterNodeNameConflict

{{< code lang="yaml" >}}
alert: ClusterNodeNameConflict
annotations:
  message: A node tried to join the cluster with a name conflicting with an existing peer.
expr: sum by (cluster, namespace) (rate(cluster_node_gossip_received_events_total{event="node_conflict"}[2m])) > 0
for: 10m
{{< /code >}}
 
##### ClusterNodeStuckTerminating

{{< code lang="yaml" >}}
alert: ClusterNodeStuckTerminating
annotations:
  message: Cluster node stuck in Terminating state.
expr: sum by (cluster, namespace, instance) (cluster_node_peers{state="terminating"}) > 0
for: 5m
{{< /code >}}
 
##### ClusterConfigurationDrift

{{< code lang="yaml" >}}
alert: ClusterConfigurationDrift
annotations:
  message: Cluster nodes are not using the same configuration file.
expr: |
  count without (sha256) (
      max by (cluster, namespace, sha256) (agent_config_hash and on(cluster, namespace) cluster_node_info)
  ) > 1
for: 5m
{{< /code >}}
 
### agent_controller

##### SlowComponentEvaluations

{{< code lang="yaml" >}}
alert: SlowComponentEvaluations
annotations:
  message: Flow component evaluations are taking too long.
expr: sum by (cluster, namespace, component_id) (rate(agent_component_evaluation_slow_seconds[10m])) > 0
for: 15m
{{< /code >}}
 
##### UnhealthyComponents

{{< code lang="yaml" >}}
alert: UnhealthyComponents
annotations:
  message: Unhealthy Flow components detected.
expr: sum(agent_component_controller_running_components{health_type!="healthy"}) > 0
for: 15m
{{< /code >}}
 
## Dashboards
Following dashboards are generated from mixins and hosted on github:


- [agent-cluster-node](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-cluster-node.json)
- [agent-cluster-overview](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-cluster-overview.json)
- [agent-flow-controller](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-flow-controller.json)
- [agent-flow-prometheus-remote-write](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-flow-prometheus-remote-write.json)
- [agent-flow-resources](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-flow-resources.json)
