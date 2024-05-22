---
title: etcd
---

## Overview

A set of customisable Prometheus alerts for etcd.

{{< panel style="danger" >}}
Jsonnet 源码地址：[github.com/etcd-io/etcd](https://github.com/etcd-io/etcd/tree/master/contrib/mixin)
{{< /panel >}}

## Alerts

{{< panel style="warning" >}}
告警Alerts配置列表 [源文件](https://github.com/observeproject/sites/blob/main/assets/etcd/alerts.yaml).
{{< /panel >}}

### etcd

##### etcdMembersDown

{{< code lang="yaml" >}}
alert: etcdMembersDown
annotations:
  description: 'etcd cluster "{{ $labels.job }}": members are down ({{ $value }}).'
  summary: etcd cluster members are down.
expr: |
  max without (endpoint) (
    sum without (instance) (up{job=~".*etcd.*"} == bool 0)
  or
    count without (To) (
      sum without (instance) (rate(etcd_network_peer_sent_failures_total{job=~".*etcd.*"}[120s])) > 0.01
    )
  )
  > 0
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### etcdInsufficientMembers

{{< code lang="yaml" >}}
alert: etcdInsufficientMembers
annotations:
  description: 'etcd cluster "{{ $labels.job }}": insufficient members ({{ $value }}).'
  summary: etcd cluster has insufficient number of members.
expr: |
  sum(up{job=~".*etcd.*"} == bool 1) without (instance) < ((count(up{job=~".*etcd.*"}) without (instance) + 1) / 2)
for: 3m
labels:
  severity: critical
{{< /code >}}
 
##### etcdNoLeader

{{< code lang="yaml" >}}
alert: etcdNoLeader
annotations:
  description: 'etcd cluster "{{ $labels.job }}": member {{ $labels.instance }} has no leader.'
  summary: etcd cluster has no leader.
expr: |
  etcd_server_has_leader{job=~".*etcd.*"} == 0
for: 1m
labels:
  severity: critical
{{< /code >}}
 
##### etcdHighNumberOfLeaderChanges

{{< code lang="yaml" >}}
alert: etcdHighNumberOfLeaderChanges
annotations:
  description: 'etcd cluster "{{ $labels.job }}": {{ $value }} leader changes within the last 15 minutes. Frequent elections may be a sign of insufficient resources, high network latency, or disruptions by other components and should be investigated.'
  summary: etcd cluster has high number of leader changes.
expr: |
  increase((max without (instance) (etcd_server_leader_changes_seen_total{job=~".*etcd.*"}) or 0*absent(etcd_server_leader_changes_seen_total{job=~".*etcd.*"}))[15m:1m]) >= 4
for: 5m
labels:
  severity: warning
{{< /code >}}
 
##### etcdHighNumberOfFailedGRPCRequests

{{< code lang="yaml" >}}
alert: etcdHighNumberOfFailedGRPCRequests
annotations:
  description: 'etcd cluster "{{ $labels.job }}": {{ $value }}% of requests for {{ $labels.grpc_method }} failed on etcd instance {{ $labels.instance }}.'
  summary: etcd cluster has high number of failed grpc requests.
expr: |
  100 * sum(rate(grpc_server_handled_total{job=~".*etcd.*", grpc_code=~"Unknown|FailedPrecondition|ResourceExhausted|Internal|Unavailable|DataLoss|DeadlineExceeded"}[5m])) without (grpc_type, grpc_code)
    /
  sum(rate(grpc_server_handled_total{job=~".*etcd.*"}[5m])) without (grpc_type, grpc_code)
    > 1
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### etcdHighNumberOfFailedGRPCRequests

{{< code lang="yaml" >}}
alert: etcdHighNumberOfFailedGRPCRequests
annotations:
  description: 'etcd cluster "{{ $labels.job }}": {{ $value }}% of requests for {{ $labels.grpc_method }} failed on etcd instance {{ $labels.instance }}.'
  summary: etcd cluster has high number of failed grpc requests.
expr: |
  100 * sum(rate(grpc_server_handled_total{job=~".*etcd.*", grpc_code=~"Unknown|FailedPrecondition|ResourceExhausted|Internal|Unavailable|DataLoss|DeadlineExceeded"}[5m])) without (grpc_type, grpc_code)
    /
  sum(rate(grpc_server_handled_total{job=~".*etcd.*"}[5m])) without (grpc_type, grpc_code)
    > 5
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### etcdGRPCRequestsSlow

{{< code lang="yaml" >}}
alert: etcdGRPCRequestsSlow
annotations:
  description: 'etcd cluster "{{ $labels.job }}": 99th percentile of gRPC requests is {{ $value }}s on etcd instance {{ $labels.instance }} for {{ $labels.grpc_method }} method.'
  summary: etcd grpc requests are slow
expr: |
  histogram_quantile(0.99, sum(rate(grpc_server_handling_seconds_bucket{job=~".*etcd.*", grpc_method!="Defragment", grpc_type="unary"}[5m])) without(grpc_type))
  > 0.15
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### etcdMemberCommunicationSlow

{{< code lang="yaml" >}}
alert: etcdMemberCommunicationSlow
annotations:
  description: 'etcd cluster "{{ $labels.job }}": member communication with {{ $labels.To }} is taking {{ $value }}s on etcd instance {{ $labels.instance }}.'
  summary: etcd cluster member communication is slow.
expr: |
  histogram_quantile(0.99, rate(etcd_network_peer_round_trip_time_seconds_bucket{job=~".*etcd.*"}[5m]))
  > 0.15
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### etcdHighNumberOfFailedProposals

{{< code lang="yaml" >}}
alert: etcdHighNumberOfFailedProposals
annotations:
  description: 'etcd cluster "{{ $labels.job }}": {{ $value }} proposal failures within the last 30 minutes on etcd instance {{ $labels.instance }}.'
  summary: etcd cluster has high number of proposal failures.
expr: |
  rate(etcd_server_proposals_failed_total{job=~".*etcd.*"}[15m]) > 5
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### etcdHighFsyncDurations

{{< code lang="yaml" >}}
alert: etcdHighFsyncDurations
annotations:
  description: 'etcd cluster "{{ $labels.job }}": 99th percentile fsync durations are {{ $value }}s on etcd instance {{ $labels.instance }}.'
  summary: etcd cluster 99th percentile fsync durations are too high.
expr: |
  histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket{job=~".*etcd.*"}[5m]))
  > 0.5
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### etcdHighFsyncDurations

{{< code lang="yaml" >}}
alert: etcdHighFsyncDurations
annotations:
  description: 'etcd cluster "{{ $labels.job }}": 99th percentile fsync durations are {{ $value }}s on etcd instance {{ $labels.instance }}.'
  summary: etcd cluster 99th percentile fsync durations are too high.
expr: |
  histogram_quantile(0.99, rate(etcd_disk_wal_fsync_duration_seconds_bucket{job=~".*etcd.*"}[5m]))
  > 1
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### etcdHighCommitDurations

{{< code lang="yaml" >}}
alert: etcdHighCommitDurations
annotations:
  description: 'etcd cluster "{{ $labels.job }}": 99th percentile commit durations {{ $value }}s on etcd instance {{ $labels.instance }}.'
  summary: etcd cluster 99th percentile commit durations are too high.
expr: |
  histogram_quantile(0.99, rate(etcd_disk_backend_commit_duration_seconds_bucket{job=~".*etcd.*"}[5m]))
  > 0.25
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### etcdDatabaseQuotaLowSpace

{{< code lang="yaml" >}}
alert: etcdDatabaseQuotaLowSpace
annotations:
  description: 'etcd cluster "{{ $labels.job }}": database size exceeds the defined quota on etcd instance {{ $labels.instance }}, please defrag or increase the quota as the writes to etcd will be disabled when it is full.'
  summary: etcd cluster database is running full.
expr: |
  (last_over_time(etcd_mvcc_db_total_size_in_bytes{job=~".*etcd.*"}[5m]) / last_over_time(etcd_server_quota_backend_bytes{job=~".*etcd.*"}[5m]))*100 > 95
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### etcdExcessiveDatabaseGrowth

{{< code lang="yaml" >}}
alert: etcdExcessiveDatabaseGrowth
annotations:
  description: 'etcd cluster "{{ $labels.job }}": Predicting running out of disk space in the next four hours, based on write observations within the past four hours on etcd instance {{ $labels.instance }}, please check as it might be disruptive.'
  summary: etcd cluster database growing very fast.
expr: |
  predict_linear(etcd_mvcc_db_total_size_in_bytes{job=~".*etcd.*"}[4h], 4*60*60) > etcd_server_quota_backend_bytes{job=~".*etcd.*"}
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### etcdDatabaseHighFragmentationRatio

{{< code lang="yaml" >}}
alert: etcdDatabaseHighFragmentationRatio
annotations:
  description: 'etcd cluster "{{ $labels.job }}": database size in use on instance {{ $labels.instance }} is {{ $value | humanizePercentage }} of the actual allocated disk space, please run defragmentation (e.g. etcdctl defrag) to retrieve the unused fragmented disk space.'
  runbook_url: https://etcd.io/docs/v3.5/op-guide/maintenance/#defragmentation
  summary: etcd database size in use is less than 50% of the actual allocated storage.
expr: |
  (last_over_time(etcd_mvcc_db_total_size_in_use_in_bytes{job=~".*etcd.*"}[5m]) / last_over_time(etcd_mvcc_db_total_size_in_bytes{job=~".*etcd.*"}[5m])) < 0.5 and etcd_mvcc_db_total_size_in_use_in_bytes{job=~".*etcd.*"} > 104857600
for: 10m
labels:
  severity: warning
{{< /code >}}
 
## Dashboards
仪表盘配置文件下载地址:


- [etcd](https://github.com/observeproject/sites/blob/main/assets/etcd/dashboards/etcd.json)