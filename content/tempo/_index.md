---
title: tempo
---

## Overview



{{< panel style="danger" >}}
Jsonnet 源码地址：[github.com/grafana/tempo](https://github.com/grafana/tempo/tree/master/operations/tempo-mixin)
{{< /panel >}}

## Alerts

{{< panel style="warning" >}}
告警Alerts配置列表 [源文件](https://github.com/observeproject/sites/blob/main/assets/tempo/alerts.yaml).
{{< /panel >}}

### tempo_alerts

##### TempoCompactorUnhealthy

{{< code lang="yaml" >}}
alert: TempoCompactorUnhealthy
annotations:
  message: There are {{ printf "%f" $value }} unhealthy compactor(s).
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoCompactorUnhealthy
expr: |
  max by (cluster, namespace) (tempo_ring_members{state="Unhealthy", name="compactor", namespace=~".*"}) > 0
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### TempoDistributorUnhealthy

{{< code lang="yaml" >}}
alert: TempoDistributorUnhealthy
annotations:
  message: There are {{ printf "%f" $value }} unhealthy distributor(s).
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoDistributorUnhealthy
expr: |
  max by (cluster, namespace) (tempo_ring_members{state="Unhealthy", name="distributor", namespace=~".*"}) > 0
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### TempoIngesterUnhealthy

{{< code lang="yaml" >}}
alert: TempoIngesterUnhealthy
annotations:
  message: There are {{ printf "%f" $value }} unhealthy ingester(s).
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoIngesterUnhealthy
expr: |
  max by (cluster, namespace) (tempo_ring_members{state="Unhealthy", name="ingester", namespace=~".*"}) > 0
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### TempoMetricsGeneratorUnhealthy

{{< code lang="yaml" >}}
alert: TempoMetricsGeneratorUnhealthy
annotations:
  message: There are {{ printf "%f" $value }} unhealthy metric-generator(s).
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoMetricsGeneratorUnhealthy
expr: |
  max by (cluster, namespace) (tempo_ring_members{state="Unhealthy", name="metrics-generator", namespace=~".*"}) > 0
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### TempoCompactionsFailing

{{< code lang="yaml" >}}
alert: TempoCompactionsFailing
annotations:
  message: Greater than 2 compactions have failed in the past hour.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoCompactionsFailing
expr: |
  sum by (cluster, namespace) (increase(tempodb_compaction_errors_total{}[1h])) > 2 and
  sum by (cluster, namespace) (increase(tempodb_compaction_errors_total{}[5m])) > 0
for: 1h
labels:
  severity: critical
{{< /code >}}
 
##### TempoIngesterFlushesUnhealthy

{{< code lang="yaml" >}}
alert: TempoIngesterFlushesUnhealthy
annotations:
  message: Greater than 2 flush retries have occurred in the past hour.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoIngesterFlushesFailing
expr: |
  sum by (cluster, namespace) (increase(tempo_ingester_failed_flushes_total{}[1h])) > 2 and
  sum by (cluster, namespace) (increase(tempo_ingester_failed_flushes_total{}[5m])) > 0
for: 5m
labels:
  severity: warning
{{< /code >}}
 
##### TempoIngesterFlushesFailing

{{< code lang="yaml" >}}
alert: TempoIngesterFlushesFailing
annotations:
  message: Greater than 2 flush retries have failed in the past hour.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoIngesterFlushesFailing
expr: |
  sum by (cluster, namespace) (increase(tempo_ingester_flush_failed_retries_total{}[1h])) > 2 and
  sum by (cluster, namespace) (increase(tempo_ingester_flush_failed_retries_total{}[5m])) > 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### TempoPollsFailing

{{< code lang="yaml" >}}
alert: TempoPollsFailing
annotations:
  message: Greater than 2 polls have failed in the past hour.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoPollsFailing
expr: |
  sum by (cluster, namespace) (increase(tempodb_blocklist_poll_errors_total{}[1h])) > 2 and
  sum by (cluster, namespace) (increase(tempodb_blocklist_poll_errors_total{}[5m])) > 0
labels:
  severity: critical
{{< /code >}}
 
##### TempoTenantIndexFailures

{{< code lang="yaml" >}}
alert: TempoTenantIndexFailures
annotations:
  message: Greater than 2 tenant index failures in the past hour.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoTenantIndexFailures
expr: |
  sum by (cluster, namespace) (increase(tempodb_blocklist_tenant_index_errors_total{}[1h])) > 2 and
  sum by (cluster, namespace) (increase(tempodb_blocklist_tenant_index_errors_total{}[5m])) > 0
labels:
  severity: critical
{{< /code >}}
 
##### TempoNoTenantIndexBuilders

{{< code lang="yaml" >}}
alert: TempoNoTenantIndexBuilders
annotations:
  message: No tenant index builders for tenant {{ $labels.tenant }}. Tenant index will quickly become stale.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoNoTenantIndexBuilders
expr: |
  sum by (cluster, namespace, tenant) (tempodb_blocklist_tenant_index_builder{}) == 0 and
  max by (cluster, namespace) (tempodb_blocklist_length{}) > 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### TempoTenantIndexTooOld

{{< code lang="yaml" >}}
alert: TempoTenantIndexTooOld
annotations:
  message: Tenant index age is 600 seconds old for tenant {{ $labels.tenant }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoTenantIndexTooOld
expr: |
  max by (cluster, namespace, tenant) (tempodb_blocklist_tenant_index_age_seconds{}) > 600
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### TempoBlockListRisingQuickly

{{< code lang="yaml" >}}
alert: TempoBlockListRisingQuickly
annotations:
  message: Tempo block list length is up 40 percent over the last 7 days.  Consider scaling compactors.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoBlockListRisingQuickly
expr: |
  avg(tempodb_blocklist_length{namespace=~".*", container="compactor"}) / avg(tempodb_blocklist_length{namespace=~".*", container="compactor"} offset 7d) by (cluster, namespace) > 1.4
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### TempoBadOverrides

{{< code lang="yaml" >}}
alert: TempoBadOverrides
annotations:
  message: '{{ $labels.job }} failed to reload overrides.'
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoBadOverrides
expr: |
  sum(tempo_runtime_config_last_reload_successful{namespace=~".*"} == 0) by (cluster, namespace, job)
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### TempoUserConfigurableOverridesReloadFailing

{{< code lang="yaml" >}}
alert: TempoUserConfigurableOverridesReloadFailing
annotations:
  message: Greater than 5 user-configurable overides reloads failed in the past hour.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoTenantIndexFailures
expr: |
  sum by (cluster, namespace) (increase(tempo_overrides_user_configurable_overrides_reload_failed_total{}[1h])) > 5 and
  sum by (cluster, namespace) (increase(tempo_overrides_user_configurable_overrides_reload_failed_total{}[5m])) > 0
labels:
  severity: critical
{{< /code >}}
 
##### TempoProvisioningTooManyWrites

{{< code lang="yaml" >}}
alert: TempoProvisioningTooManyWrites
annotations:
  message: Ingesters in {{ $labels.cluster }}/{{ $labels.namespace }} are receiving more data/second than desired, add more ingesters.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoProvisioningTooManyWrites
expr: |
  avg by (cluster, namespace) (rate(tempo_ingester_bytes_received_total{job=~".+/ingester"}[5m])) / 1024 / 1024 > 30
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### TempoCompactorsTooManyOutstandingBlocks

{{< code lang="yaml" >}}
alert: TempoCompactorsTooManyOutstandingBlocks
annotations:
  message: There are too many outstanding compaction blocks in {{ $labels.cluster }}/{{ $labels.namespace }} for tenant {{ $labels.tenant }}, increase compactor's CPU or add more compactors.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoCompactorsTooManyOutstandingBlocks
expr: |
  sum by (cluster, namespace, tenant) (tempodb_compaction_outstanding_blocks{container="compactor", namespace=~".*"}) / ignoring(tenant) group_left count(tempo_build_info{container="compactor", namespace=~".*"}) by (cluster, namespace) > 100
for: 6h
labels:
  severity: warning
{{< /code >}}
 
##### TempoCompactorsTooManyOutstandingBlocks

{{< code lang="yaml" >}}
alert: TempoCompactorsTooManyOutstandingBlocks
annotations:
  message: There are too many outstanding compaction blocks in {{ $labels.cluster }}/{{ $labels.namespace }} for tenant {{ $labels.tenant }}, increase compactor's CPU or add more compactors.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoCompactorsTooManyOutstandingBlocks
expr: |
  sum by (cluster, namespace, tenant) (tempodb_compaction_outstanding_blocks{container="compactor", namespace=~".*"}) / ignoring(tenant) group_left count(tempo_build_info{container="compactor", namespace=~".*"}) by (cluster, namespace) > 250
for: 24h
labels:
  severity: critical
{{< /code >}}
 
##### TempoIngesterReplayErrors

{{< code lang="yaml" >}}
alert: TempoIngesterReplayErrors
annotations:
  message: Tempo ingester has encountered errors while replaying a block on startup in {{ $labels.cluster }}/{{ $labels.namespace }} for tenant {{ $labels.tenant }}
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoIngesterReplayErrors
expr: |
  sum by (cluster, namespace, tenant) (increase(tempo_ingester_replay_errors_total{namespace=~".*"}[5m])) > 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### TempoMetricsGeneratorPartitionLagCritical

{{< code lang="yaml" >}}
alert: TempoMetricsGeneratorPartitionLagCritical
annotations:
  message: Tempo partition {{ $labels.partition }} in consumer group {{ $labels.group }} is lagging by more than 900 seconds in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoPartitionLag
expr: |
  max by (cluster, namespace, partition) (tempo_ingest_group_partition_lag_seconds{namespace=~".*", container="metrics-generator"}) > 900
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### TempoBlockBuilderPartitionLagWarning

{{< code lang="yaml" >}}
alert: TempoBlockBuilderPartitionLagWarning
annotations:
  message: Tempo ingest partition {{ $labels.partition }} for blockbuilder {{ $labels.pod }} is lagging by more than 300 seconds in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoPartitionLag
expr: |
  max by (cluster, namespace, partition) (avg_over_time(tempo_ingest_group_partition_lag_seconds{namespace=~".*", container="block-builder"}[6m])) > 200
for: 5m
labels:
  severity: warning
{{< /code >}}
 
##### TempoBlockBuilderPartitionLagCritical

{{< code lang="yaml" >}}
alert: TempoBlockBuilderPartitionLagCritical
annotations:
  message: Tempo ingest partition {{ $labels.partition }} for blockbuilder {{ $labels.pod }} is lagging by more than 300 seconds in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoPartitionLag
expr: |
  max by (cluster, namespace, partition) (avg_over_time(tempo_ingest_group_partition_lag_seconds{namespace=~".*", container=~"block-builder"}[6m])) > 300
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### TempoBackendSchedulerJobsFailureRateHigh

{{< code lang="yaml" >}}
alert: TempoBackendSchedulerJobsFailureRateHigh
annotations:
  message: Tempo backend scheduler job failure rate is {{ printf "%0.2f" $value }} (threshold 0.1) in {{ $labels.cluster }}/{{ $labels.namespace }}
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoBackendSchedulerJobsFailureRateHigh
expr: |
  sum(increase(tempo_backend_scheduler_jobs_failed_total{namespace=~".*"}[5m])) by (cluster, namespace)
  /
  sum(increase(tempo_backend_scheduler_jobs_created_total{namespace=~".*"}[5m])) by (cluster, namespace)
  > 0.05
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### TempoBackendSchedulerRetryRateHigh

{{< code lang="yaml" >}}
alert: TempoBackendSchedulerRetryRateHigh
annotations:
  message: Tempo backend scheduler retry rate is high ({{ printf "%0.2f" $value }} retries/minute) in {{ $labels.cluster }}/{{ $labels.namespace }}
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoBackendSchedulerRetryRateHigh
expr: |
  sum(increase(tempo_backend_scheduler_jobs_retry_total{namespace=~".*"}[1m])) by (cluster, namespace) > 20
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### TempoBackendSchedulerCompactionEmptyJobRateHigh

{{< code lang="yaml" >}}
alert: TempoBackendSchedulerCompactionEmptyJobRateHigh
annotations:
  message: Tempo backend scheduler empty job rate is high ({{ printf "%0.2f" $value }} jobs/minute) in {{ $labels.cluster }}/{{ $labels.namespace }}
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoBackendSchedulerCompactionEmptyJobRateHigh
expr: |
  sum(increase(tempo_backend_scheduler_compaction_tenant_empty_job_total{namespace=~".*"}[1m])) by (cluster, namespace) > 10
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### TempoBackendWorkerBadJobsRateHigh

{{< code lang="yaml" >}}
alert: TempoBackendWorkerBadJobsRateHigh
annotations:
  message: Tempo backend worker bad jobs rate is high ({{ printf "%0.2f" $value }} bad jobs/minute) in {{ $labels.cluster }}/{{ $labels.namespace }}
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoBackendWorkerBadJobsRateHigh
expr: |
  sum(increase(tempo_backend_worker_bad_jobs_received_total{namespace=~".*"}[1m])) by (cluster, namespace) > 0
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### TempoBackendWorkerCallRetriesHigh

{{< code lang="yaml" >}}
alert: TempoBackendWorkerCallRetriesHigh
annotations:
  message: Tempo backend worker call retries rate is high ({{ printf "%0.2f" $value }} retries/minute) in {{ $labels.cluster }}/{{ $labels.namespace }}
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoBackendWorkerCallRetriesHigh
expr: |
  sum(increase(tempo_backend_worker_call_retries_total{namespace=~".*"}[1m])) by (cluster, namespace) > 5
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### TempoVultureHighErrorRate

{{< code lang="yaml" >}}
alert: TempoVultureHighErrorRate
annotations:
  message: Tempo vulture error rate is {{ printf "%0.2f" $value }} for error type {{ $labels.error }} in {{ $labels.cluster }}/{{ $labels.namespace }}
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoVultureHighErrorRate
expr: |
  sum(rate(tempo_vulture_trace_error_total{namespace=~".*"}[1m])) by (cluster, namespace, error) / ignoring (error) group_left sum(rate(tempo_vulture_trace_total{namespace=~".*"}[1m])) by (cluster, namespace) > 0.200000
for: 5m
labels:
  severity: warning
{{< /code >}}
 
## Recording Rules

{{< panel style="warning" >}}
指标计算Recording规则配置列表 [源文件](https://github.com/observeproject/sites/blob/main/assets/tempo/rules.yaml).
{{< /panel >}}

### tempo_rules

##### cluster_namespace_job_route:tempo_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(tempo_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route))
record: cluster_namespace_job_route:tempo_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_namespace_job_route:tempo_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(tempo_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route))
record: cluster_namespace_job_route:tempo_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_namespace_job_route:tempo_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(tempo_request_duration_seconds_sum[1m])) by (cluster, namespace, job, route) / sum(rate(tempo_request_duration_seconds_count[1m])) by (cluster, namespace, job, route)
record: cluster_namespace_job_route:tempo_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_namespace_job_route:tempo_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(tempo_request_duration_seconds_bucket[1m])) by (le, cluster, namespace, job, route)
record: cluster_namespace_job_route:tempo_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_namespace_job_route:tempo_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(tempo_request_duration_seconds_sum[1m])) by (cluster, namespace, job, route)
record: cluster_namespace_job_route:tempo_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_namespace_job_route:tempo_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(tempo_request_duration_seconds_count[1m])) by (cluster, namespace, job, route)
record: cluster_namespace_job_route:tempo_request_duration_seconds_count:sum_rate
{{< /code >}}
 
## Dashboards
仪表盘配置文件下载地址:


- [tempo-backendwork](https://github.com/observeproject/sites/blob/main/assets/tempo/dashboards/tempo-backendwork.json)
- [tempo-block-builder](https://github.com/observeproject/sites/blob/main/assets/tempo/dashboards/tempo-block-builder.json)
- [tempo-operational](https://github.com/observeproject/sites/blob/main/assets/tempo/dashboards/tempo-operational.json)
- [tempo-reads](https://github.com/observeproject/sites/blob/main/assets/tempo/dashboards/tempo-reads.json)
- [tempo-resources](https://github.com/observeproject/sites/blob/main/assets/tempo/dashboards/tempo-resources.json)
- [tempo-rollout-progress](https://github.com/observeproject/sites/blob/main/assets/tempo/dashboards/tempo-rollout-progress.json)
- [tempo-tenants](https://github.com/observeproject/sites/blob/main/assets/tempo/dashboards/tempo-tenants.json)
- [tempo-writes](https://github.com/observeproject/sites/blob/main/assets/tempo/dashboards/tempo-writes.json)
