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
 
##### TempoLiveStoreUnhealthy

{{< code lang="yaml" >}}
alert: TempoLiveStoreUnhealthy
annotations:
  message: There are {{ printf "%f" $value }} unhealthy livestore(s).
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoLiveStoreUnhealthy
expr: |
  max by (cluster, namespace) (tempo_ring_members{state="Unhealthy", name="live-store", namespace=~".*"}) > 0
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
  message: Tempo block list length is up 40 percent over the last 7 days. Consider scaling compactors.
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
 
##### TempoCompactionTooManyOutstandingBlocks

{{< code lang="yaml" >}}
alert: TempoCompactionTooManyOutstandingBlocks
annotations:
  message: There are too many outstanding compaction blocks in {{ $labels.cluster }}/{{ $labels.namespace }} for tenant {{ $labels.tenant }}, increase compactor's CPU or add more compactors.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoCompactionTooManyOutstandingBlocks
expr: |
  sum by (cluster, namespace, tenant) (tempodb_compaction_outstanding_blocks{container="compactor", namespace=~".*"}) / ignoring(tenant) group_left count(tempo_build_info{container="compactor", namespace=~".*"}) by (cluster, namespace) > 100
for: 6h
labels:
  severity: warning
{{< /code >}}
 
##### TempoCompactionTooManyOutstandingBlocks

{{< code lang="yaml" >}}
alert: TempoCompactionTooManyOutstandingBlocks
annotations:
  message: There are too many outstanding compaction blocks in {{ $labels.cluster }}/{{ $labels.namespace }} for tenant {{ $labels.tenant }}, increase compactor's CPU or add more compactors.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoCompactionTooManyOutstandingBlocks
expr: |
  sum by (cluster, namespace, tenant) (tempodb_compaction_outstanding_blocks{container="compactor", namespace=~".*"}) / ignoring(tenant) group_left count(tempo_build_info{container="compactor", namespace=~".*"}) by (cluster, namespace) > 250
for: 24h
labels:
  severity: critical
{{< /code >}}
 
##### TempoMetricsGeneratorPartitionLagCritical

{{< code lang="yaml" >}}
alert: TempoMetricsGeneratorPartitionLagCritical
annotations:
  message: Tempo partition {{ $labels.partition }} is lagging by more than 900 seconds in {{ $labels.cluster }}/{{ $labels.namespace }}.
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
  message: Tempo ingest partition {{ $labels.partition }} for blockbuilder is lagging by more than 300 seconds in {{ $labels.cluster }}/{{ $labels.namespace }}.
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
  message: Tempo ingest partition {{ $labels.partition }} for blockbuilder is lagging by more than 300 seconds in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoPartitionLag
expr: |
  max by (cluster, namespace, partition) (avg_over_time(tempo_ingest_group_partition_lag_seconds{namespace=~".*", container=~"block-builder"}[6m])) > 300
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### TempoLiveStorePartitionLagWarning

{{< code lang="yaml" >}}
alert: TempoLiveStorePartitionLagWarning
annotations:
  message: Tempo ingest partition {{ $labels.partition }} for live store {{ $labels.group }} is lagging by more than 300 seconds in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoPartitionLag
expr: |
  max by (cluster, namespace, partition, group) (avg_over_time(tempo_ingest_group_partition_lag_seconds{namespace=~".*", container="live-store"}[6m])) > 200
for: 5m
labels:
  severity: warning
{{< /code >}}
 
##### TempoLiveStorePartitionLagCritical

{{< code lang="yaml" >}}
alert: TempoLiveStorePartitionLagCritical
annotations:
  message: Tempo ingest partition {{ $labels.partition }} for live store group {{ $labels.group }} is lagging by more than 300 seconds in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoPartitionLag
expr: |
  max by (cluster, namespace, partition, group) (avg_over_time(tempo_ingest_group_partition_lag_seconds{namespace=~".*", container=~"live-store"}[6m])) > 300
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
  sum(rate(tempo_vulture_trace_error_total{namespace=~".*"}[1m])) by (cluster, namespace, error) / ignoring (error) group_left sum(rate(tempo_vulture_trace_total{namespace=~".*"}[1m])) by (cluster, namespace) > 0.100000
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### TempoMemcachedErrorsElevated

{{< code lang="yaml" >}}
alert: TempoMemcachedErrorsElevated
annotations:
  message: Tempo memcached error rate is {{ printf "%0.2f" $value }} for role {{ $labels.name }} in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoMemcachedErrorsElevated
expr: |
  sum(rate(tempo_memcache_request_duration_seconds_count{status_code="500"}[5m])) by (cluster, namespace, name)
  /
  sum(rate(tempo_memcache_request_duration_seconds_count{}[5m])) by (cluster, namespace, name) > 0.2
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### TempoBlockBuildersPartitionsMismatch

{{< code lang="yaml" >}}
alert: TempoBlockBuildersPartitionsMismatch
annotations:
  message: Tempo block-builder partitions mismatch in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoBlockBuildersPartitionsMismatch
expr: |
  max(tempo_partition_ring_partitions{name=~"livestore-partitions", state=~"Active|Inactive"}) by (namespace,cluster)
  >
  sum(tempo_block_builder_owned_partitions) by(namespace,cluster)
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### TempoLiveStoresPartitionsUnowned

{{< code lang="yaml" >}}
alert: TempoLiveStoresPartitionsUnowned
annotations:
  message: Some live-store partitions are unowned in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoLiveStoresPartitionsUnowned
expr: |
  max by(namespace, cluster) (
    tempo_partition_ring_partitions{name=~"livestore-partitions", state=~"Active|Inactive"}
  )
  >
  count(count by (partition,namespace,cluster) (
    tempo_live_store_partition_owned{}
  )) by (namespace, cluster)
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### TempoLiveStoreZoneSeverelyDegraded

{{< code lang="yaml" >}}
alert: TempoLiveStoreZoneSeverelyDegraded
annotations:
  message: Live-store zone {{ $labels.zone }} owns far fewer partitions than peers in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoLiveStoreZoneSeverelyDegraded
expr: |
  abs(
    (
      count by (namespace, cluster, zone) (tempo_live_store_partition_owned)
      /
      on(namespace, cluster)
      group_left()
      max by (namespace, cluster) (count by (namespace, cluster, zone) (tempo_live_store_partition_owned))
     ) - 1
   ) > 0.6
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### TempoDistributorUsageTrackerErrors

{{< code lang="yaml" >}}
alert: TempoDistributorUsageTrackerErrors
annotations:
  message: 'Tempo distributor usage tracker errors for tenant {{ $labels.tenant }} in {{ $labels.cluster }}/{{ $labels.namespace }} (reason: {{ $labels.reason }}).'
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoDistributorUsageTrackerErrors
expr: |
  sum by (cluster, namespace, tenant, reason)(rate(tempo_distributor_usage_tracker_errors_total{}[5m])) > 0
for: 30m
labels:
  severity: critical
{{< /code >}}
 
##### TempoMetricsGeneratorProcessorUpdatesFailing

{{< code lang="yaml" >}}
alert: TempoMetricsGeneratorProcessorUpdatesFailing
annotations:
  message: Metrics-generator processor updates are failing for tenant {{ $labels.tenant }} in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoMetricsGeneratorProcessorUpdatesFailing
expr: |
  sum by (cluster, namespace, tenant) (
    increase(tempo_metrics_generator_active_processors_update_failed_total{namespace=~".*"}[5m])
  ) > 0
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### TempoMetricsGeneratorServiceGraphsDroppingSpans

{{< code lang="yaml" >}}
alert: TempoMetricsGeneratorServiceGraphsDroppingSpans
annotations:
  message: Metrics-generator service-graphs processor is dropping {{ $value | humanizePercentage }} spans for tenant {{ $labels.tenant }} in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoMetricsGeneratorServiceGraphsDroppingSpans
expr: |
  sum by (cluster, namespace, tenant) (increase(tempo_metrics_generator_processor_service_graphs_dropped_spans{namespace=~".*"}[1h]))
  /
  sum by (cluster, namespace, tenant) (increase(tempo_metrics_generator_spans_received_total{namespace=~".*"}[1h]))
  > 0.005
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### TempoMetricsGeneratorCollectionsFailing

{{< code lang="yaml" >}}
alert: TempoMetricsGeneratorCollectionsFailing
annotations:
  message: Metrics-generator collections are failing for tenant {{ $labels.tenant }} in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://github.com/grafana/tempo/tree/main/operations/tempo-mixin/runbook.md#TempoMetricsGeneratorCollectionsFailing
expr: |
  sum by (cluster, namespace, tenant, pod, job) (increase(tempo_metrics_generator_registry_collections_failed_total{namespace=~".*"}[5m])) > 2
for: 5m
labels:
  severity: critical
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
