---
title: grafana-agent
---

## Overview



{{< panel style="danger" >}}
Jsonnet 源码地址：[github.com/grafana/agent.git](https://github.com/grafana/agent.git/tree/master/operations/agent-flow-mixin)
{{< /panel >}}

## Alerts

{{< panel style="warning" >}}
告警Alerts配置列表 [源文件](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/alerts.yaml).
{{< /panel >}}

### clustering

##### ClusterNotConverging

{{< code lang="yaml" >}}
alert: ClusterNotConverging
annotations:
  message: 'Cluster is not converging: nodes report different number of peers in the cluster.'
expr: stddev by (cluster, namespace) (sum without (state) (cluster_node_peers)) != 0
for: 10m
{{< /code >}}
 
##### ClusterNodeCountMismatch

{{< code lang="yaml" >}}
alert: ClusterNodeCountMismatch
annotations:
  message: Nodes report different number of peers vs. the count of observed agent metrics. Some agent metrics may be missing or the cluster is in a split brain state.
expr: |
  sum without (state) (cluster_node_peers) !=
  on (cluster, namespace) group_left
  count by (cluster, namespace) (cluster_node_info)
for: 15m
{{< /code >}}
 
##### ClusterNodeUnhealthy

{{< code lang="yaml" >}}
alert: ClusterNodeUnhealthy
annotations:
  message: Cluster node is reporting a gossip protocol health score > 0.
expr: |
  cluster_node_gossip_health_score > 0
for: 10m
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
for: 10m
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
expr: sum by (cluster, namespace) (agent_component_controller_running_components{health_type!="healthy"}) > 0
for: 15m
{{< /code >}}
 
## Dashboards
仪表盘配置文件下载地址:


- [agent-cluster-node](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-cluster-node.json)
- [agent-cluster-overview](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-cluster-overview.json)
- [agent-flow-controller](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-flow-controller.json)
- [agent-flow-opentelemetry](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-flow-opentelemetry.json)
- [agent-flow-prometheus-remote-write](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-flow-prometheus-remote-write.json)
- [agent-flow-resources](https://github.com/observeproject/sites/blob/main/assets/grafana-agent/dashboards/agent-flow-resources.json)
