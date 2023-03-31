---
title: mimir
---

## Overview

The mimir Mixin is a set of configurable, reusable, and extensible alerts and dashboards for Mimir/Cortex.

{{< panel style="danger" >}}
Jsonnet source code is available at [github.com/grafana/mimir](https://github.com/grafana/mimir/tree/master/operations/mimir-mixin)
{{< /panel >}}

## Alerts

{{< panel style="warning" >}}
Complete list of pregenerated alerts is available [here](https://github.com/observeproject/sites/blob/main/assets/mimir/alerts.yaml).
{{< /panel >}}

### mimir_alerts

##### MetricIngesterUnhealthy

{{< code lang="yaml" >}}
alert: MetricIngesterUnhealthy
annotations:
  message: Metric cluster {{ $labels.cluster }}/{{ $labels.namespace }} has {{ printf
    "%f" $value }} unhealthy ingester(s).
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterunhealthy
expr: |
  min by (cluster, namespace) (cortex_ring_members{state="Unhealthy", name="ingester"}) > 0
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### MetricRequestErrors

{{< code lang="yaml" >}}
alert: MetricRequestErrors
annotations:
  message: |
    The route {{ $labels.route }} in {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf "%.2f" $value }}% errors.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrequesterrors
expr: |
  100 * sum by (cluster, namespace, job, route) (rate(cortex_request_duration_seconds_count{status_code=~"5..",route!~"ready"}[1m]))
    /
  sum by (cluster, namespace, job, route) (rate(cortex_request_duration_seconds_count{route!~"ready"}[1m]))
    > 1
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### MetricRequestLatency

{{< code lang="yaml" >}}
alert: MetricRequestLatency
annotations:
  message: |
    {{ $labels.job }} {{ $labels.route }} is experiencing {{ printf "%.2f" $value }}s 99th percentile latency.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrequestlatency
expr: |
  cluster_namespace_job_route:cortex_request_duration_seconds:99quantile{route!~"metrics|/frontend.Frontend/Process|ready|/schedulerpb.SchedulerForFrontend/FrontendLoop|/schedulerpb.SchedulerForQuerier/QuerierLoop"}
     >
  2.5
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### MetricQueriesIncorrect

{{< code lang="yaml" >}}
alert: MetricQueriesIncorrect
annotations:
  message: |
    The Metric cluster {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf "%.2f" $value }}% incorrect query results.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricqueriesincorrect
expr: |
  100 * sum by (cluster, namespace) (rate(test_exporter_test_case_result_total{result="fail"}[5m]))
    /
  sum by (cluster, namespace) (rate(test_exporter_test_case_result_total[5m])) > 1
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### MetricInconsistentRuntimeConfig

{{< code lang="yaml" >}}
alert: MetricInconsistentRuntimeConfig
annotations:
  message: |
    An inconsistent runtime config file is used across cluster {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricinconsistentruntimeconfig
expr: |
  count(count by(cluster, namespace, job, sha256) (cortex_runtime_config_hash)) without(sha256) > 1
for: 1h
labels:
  severity: critical
{{< /code >}}
 
##### MetricBadRuntimeConfig

{{< code lang="yaml" >}}
alert: MetricBadRuntimeConfig
annotations:
  message: |
    {{ $labels.job }} failed to reload runtime config.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricbadruntimeconfig
expr: |
  # The metric value is reset to 0 on error while reloading the config at runtime.
  cortex_runtime_config_last_reload_successful == 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricFrontendQueriesStuck

{{< code lang="yaml" >}}
alert: MetricFrontendQueriesStuck
annotations:
  message: |
    There are {{ $value }} queued up queries in {{ $labels.cluster }}/{{ $labels.namespace }} {{ $labels.job }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricfrontendqueriesstuck
expr: |
  sum by (cluster, namespace, job) (min_over_time(cortex_query_frontend_queue_length[1m])) > 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricSchedulerQueriesStuck

{{< code lang="yaml" >}}
alert: MetricSchedulerQueriesStuck
annotations:
  message: |
    There are {{ $value }} queued up queries in {{ $labels.cluster }}/{{ $labels.namespace }} {{ $labels.job }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricschedulerqueriesstuck
expr: |
  sum by (cluster, namespace, job) (min_over_time(cortex_query_scheduler_queue_length[1m])) > 0
for: 7m
labels:
  severity: critical
{{< /code >}}
 
##### MetricCacheRequestErrors

{{< code lang="yaml" >}}
alert: MetricCacheRequestErrors
annotations:
  message: |
    The cache {{ $labels.name }} used by Metric {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf "%.2f" $value }}% errors for {{ $labels.operation }} operation.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccacherequesterrors
expr: |
  (
    sum by(cluster, namespace, name, operation) (
      rate(thanos_memcached_operation_failures_total[1m])
      or
      rate(thanos_cache_operation_failures_total[1m])
    )
    /
    sum by(cluster, namespace, name, operation) (
      rate(thanos_memcached_operations_total[1m])
      or
      rate(thanos_cache_operations_total[1m])
    )
  ) * 100 > 5
for: 5m
labels:
  severity: warning
{{< /code >}}
 
##### MetricIngesterRestarts

{{< code lang="yaml" >}}
alert: MetricIngesterRestarts
annotations:
  message: '{{ $labels.job }}/{{ $labels.pod }} has restarted {{ printf "%.2f" $value
    }} times in the last 30 mins.'
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterrestarts
expr: |
  changes(process_start_time_seconds{job=~".*/(ingester.*|cortex|mimir|mimir-write.*)"}[30m]) >= 2
labels:
  severity: warning
{{< /code >}}
 
##### MetricKVStoreFailure

{{< code lang="yaml" >}}
alert: MetricKVStoreFailure
annotations:
  message: |
    Metric {{ $labels.pod }} in  {{ $labels.cluster }}/{{ $labels.namespace }} is failing to talk to the KV store {{ $labels.kv_name }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metrickvstorefailure
expr: |
  (
    sum by(cluster, namespace, pod, status_code, kv_name) (rate(cortex_kv_request_duration_seconds_count{status_code!~"2.+"}[1m]))
    /
    sum by(cluster, namespace, pod, status_code, kv_name) (rate(cortex_kv_request_duration_seconds_count[1m]))
  )
  # We want to get alerted only in case there's a constant failure.
  == 1
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricMemoryMapAreasTooHigh

{{< code lang="yaml" >}}
alert: MetricMemoryMapAreasTooHigh
annotations:
  message: '{{ $labels.job }}/{{ $labels.pod }} has a number of mmap-ed areas close
    to the limit.'
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricmemorymapareastoohigh
expr: |
  process_memory_map_areas{job=~".*/(ingester.*|cortex|mimir|mimir-write.*|store-gateway.*|cortex|mimir|mimir-backend.*)"} / process_memory_map_areas_limit{job=~".*/(ingester.*|cortex|mimir|mimir-write.*|store-gateway.*|cortex|mimir|mimir-backend.*)"} > 0.8
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricDistributorForwardingErrorRate

{{< code lang="yaml" >}}
alert: MetricDistributorForwardingErrorRate
annotations:
  message: |
    Metric in {{ $labels.cluster }}/{{ $labels.namespace }} has a high failure rate when forwarding samples.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricdistributorforwardingerrorrate
expr: |
  sum by (cluster, namespace) (rate(cortex_distributor_forward_errors_total{}[1m]))
  /
  sum by (cluster, namespace) (rate(cortex_distributor_forward_requests_total{}[1m]))
  > 0.01
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterInstanceHasNoTenants

{{< code lang="yaml" >}}
alert: MetricIngesterInstanceHasNoTenants
annotations:
  message: Metric ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has no tenants assigned.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterinstancehasnotenants
expr: |
  (min by(cluster, namespace, pod) (cortex_ingester_memory_users) == 0)
  and on (cluster, namespace)
  # Only if there are more time-series than would be expected due to continuous testing load
  (
    sum by(cluster, namespace) (cortex_ingester_memory_series)
    /
    max by(cluster, namespace) (cortex_distributor_replication_factor)
  ) > 100000
for: 1h
labels:
  severity: warning
{{< /code >}}
 
##### MetricRulerInstanceHasNoRuleGroups

{{< code lang="yaml" >}}
alert: MetricRulerInstanceHasNoRuleGroups
annotations:
  message: Metric ruler {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has no rule groups assigned.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrulerinstancehasnorulegroups
expr: |
  # Alert on ruler instances in microservices mode that have no rule groups assigned,
  min by(cluster, namespace, pod) (cortex_ruler_managers_total{pod=~"(.*mimir-)?ruler.*"}) == 0
  # but only if other ruler instances of the same cell do have rule groups assigned
  and on (cluster, namespace)
  (max by(cluster, namespace) (cortex_ruler_managers_total) > 0)
  # and there are more than two instances overall
  and on (cluster, namespace)
  (count by (cluster, namespace) (cortex_ruler_managers_total) > 2)
for: 1h
labels:
  severity: warning
{{< /code >}}
 
##### MetricRingMembersMismatch

{{< code lang="yaml" >}}
alert: MetricRingMembersMismatch
annotations:
  message: |
    Number of members in Metric ingester hash ring does not match the expected number in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricringmembersmismatch
expr: |
  (
    avg by(cluster, namespace) (sum by(cluster, namespace, pod) (cortex_ring_members{name="ingester",job=~".*/(ingester.*|cortex|mimir|mimir-write.*)"}))
    != sum by(cluster, namespace) (up{job=~".*/(ingester.*|cortex|mimir|mimir-write.*)"})
  )
  and
  (
    count by(cluster, namespace) (cortex_build_info) > 0
  )
for: 15m
labels:
  component: ingester
  severity: warning
{{< /code >}}
 
### mimir_instance_limits_alerts

##### MetricIngesterReachingSeriesLimit

{{< code lang="yaml" >}}
alert: MetricIngesterReachingSeriesLimit
annotations:
  message: |
    Ingester {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its series limit.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterreachingserieslimit
expr: |
  (
      (cortex_ingester_memory_series / ignoring(limit) cortex_ingester_instance_limits{limit="max_series"})
      and ignoring (limit)
      (cortex_ingester_instance_limits{limit="max_series"} > 0)
  ) > 0.8
for: 3h
labels:
  severity: warning
{{< /code >}}
 
##### MetricIngesterReachingSeriesLimit

{{< code lang="yaml" >}}
alert: MetricIngesterReachingSeriesLimit
annotations:
  message: |
    Ingester {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its series limit.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterreachingserieslimit
expr: |
  (
      (cortex_ingester_memory_series / ignoring(limit) cortex_ingester_instance_limits{limit="max_series"})
      and ignoring (limit)
      (cortex_ingester_instance_limits{limit="max_series"} > 0)
  ) > 0.9
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterReachingTenantsLimit

{{< code lang="yaml" >}}
alert: MetricIngesterReachingTenantsLimit
annotations:
  message: |
    Ingester {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its tenant limit.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterreachingtenantslimit
expr: |
  (
      (cortex_ingester_memory_users / ignoring(limit) cortex_ingester_instance_limits{limit="max_tenants"})
      and ignoring (limit)
      (cortex_ingester_instance_limits{limit="max_tenants"} > 0)
  ) > 0.7
for: 5m
labels:
  severity: warning
{{< /code >}}
 
##### MetricIngesterReachingTenantsLimit

{{< code lang="yaml" >}}
alert: MetricIngesterReachingTenantsLimit
annotations:
  message: |
    Ingester {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its tenant limit.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterreachingtenantslimit
expr: |
  (
      (cortex_ingester_memory_users / ignoring(limit) cortex_ingester_instance_limits{limit="max_tenants"})
      and ignoring (limit)
      (cortex_ingester_instance_limits{limit="max_tenants"} > 0)
  ) > 0.8
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricReachingTCPConnectionsLimit

{{< code lang="yaml" >}}
alert: MetricReachingTCPConnectionsLimit
annotations:
  message: |
    Metric instance {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its TCP connections limit for {{ $labels.protocol }} protocol.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricreachingtcpconnectionslimit
expr: |
  cortex_tcp_connections / cortex_tcp_connections_limit > 0.8 and
  cortex_tcp_connections_limit > 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricDistributorReachingInflightPushRequestLimit

{{< code lang="yaml" >}}
alert: MetricDistributorReachingInflightPushRequestLimit
annotations:
  message: |
    Distributor {{ $labels.job }}/{{ $labels.pod }} has reached {{ $value | humanizePercentage }} of its inflight push request limit.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricdistributorreachinginflightpushrequestlimit
expr: |
  (
      (cortex_distributor_inflight_push_requests / ignoring(limit) cortex_distributor_instance_limits{limit="max_inflight_push_requests"})
      and ignoring (limit)
      (cortex_distributor_instance_limits{limit="max_inflight_push_requests"} > 0)
  ) > 0.8
for: 5m
labels:
  severity: critical
{{< /code >}}
 
### mimir-rollout-alerts

##### MetricRolloutStuck

{{< code lang="yaml" >}}
alert: MetricRolloutStuck
annotations:
  message: |
    The {{ $labels.rollout_group }} rollout is stuck in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrolloutstuck
expr: |
  (
    max without (revision) (
      sum without(statefulset) (label_replace(kube_statefulset_status_current_revision, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))
        unless
      sum without(statefulset) (label_replace(kube_statefulset_status_update_revision, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))
    )
      *
    (
      sum without(statefulset) (label_replace(kube_statefulset_replicas, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))
        !=
      sum without(statefulset) (label_replace(kube_statefulset_status_replicas_updated, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))
    )
  ) and (
    changes(sum without(statefulset) (label_replace(kube_statefulset_status_replicas_updated, "rollout_group", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?"))[15m:1m])
      ==
    0
  )
  * on(cluster, namespace) group_left max by(cluster, namespace) (cortex_build_info)
for: 30m
labels:
  severity: warning
{{< /code >}}
 
##### MetricRolloutStuck

{{< code lang="yaml" >}}
alert: MetricRolloutStuck
annotations:
  message: |
    The {{ $labels.rollout_group }} rollout is stuck in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrolloutstuck
expr: |
  (
    sum without(deployment) (label_replace(kube_deployment_spec_replicas, "rollout_group", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"))
      !=
    sum without(deployment) (label_replace(kube_deployment_status_replicas_updated, "rollout_group", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"))
  ) and (
    changes(sum without(deployment) (label_replace(kube_deployment_status_replicas_updated, "rollout_group", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"))[15m:1m])
      ==
    0
  )
  * on(cluster, namespace) group_left max by(cluster, namespace) (cortex_build_info)
for: 30m
labels:
  severity: warning
{{< /code >}}
 
##### RolloutOperatorNotReconciling

{{< code lang="yaml" >}}
alert: RolloutOperatorNotReconciling
annotations:
  message: |
    Rollout operator is not reconciling the rollout group {{ $labels.rollout_group }} in {{ $labels.cluster }}/{{ $labels.namespace }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#rolloutoperatornotreconciling
expr: |
  max by(cluster, namespace, rollout_group) (time() - rollout_operator_last_successful_group_reconcile_timestamp_seconds) > 600
for: 5m
labels:
  severity: critical
{{< /code >}}
 
### mimir-provisioning

##### MetricProvisioningTooManyActiveSeries

{{< code lang="yaml" >}}
alert: MetricProvisioningTooManyActiveSeries
annotations:
  message: |
    The number of in-memory series per ingester in {{ $labels.cluster }}/{{ $labels.namespace }} is too high.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricprovisioningtoomanyactiveseries
expr: |
  avg by (cluster, namespace) (cortex_ingester_memory_series) > 1.6e6
for: 2h
labels:
  severity: warning
{{< /code >}}
 
##### MetricProvisioningTooManyWrites

{{< code lang="yaml" >}}
alert: MetricProvisioningTooManyWrites
annotations:
  message: |
    Ingesters in {{ $labels.cluster }}/{{ $labels.namespace }} ingest too many samples per second.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricprovisioningtoomanywrites
expr: |
  avg by (cluster, namespace) (cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m) > 80e3
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### MetricAllocatingTooMuchMemory

{{< code lang="yaml" >}}
alert: MetricAllocatingTooMuchMemory
annotations:
  message: |
    Instance {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is using too much memory.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricallocatingtoomuchmemory
expr: |
  (
    # We use RSS instead of working set memory because of the ingester's extensive usage of mmap.
    # See: https://github.com/grafana/mimir/issues/2466
    container_memory_rss{container=~"(ingester|mimir-write|mimir-backend)"}
      /
    ( container_spec_memory_limit_bytes{container=~"(ingester|mimir-write|mimir-backend)"} > 0 )
  ) > 0.65
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### MetricAllocatingTooMuchMemory

{{< code lang="yaml" >}}
alert: MetricAllocatingTooMuchMemory
annotations:
  message: |
    Instance {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is using too much memory.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricallocatingtoomuchmemory
expr: |
  (
    # We use RSS instead of working set memory because of the ingester's extensive usage of mmap.
    # See: https://github.com/grafana/mimir/issues/2466
    container_memory_rss{container=~"(ingester|mimir-write|mimir-backend)"}
      /
    ( container_spec_memory_limit_bytes{container=~"(ingester|mimir-write|mimir-backend)"} > 0 )
  ) > 0.8
for: 15m
labels:
  severity: critical
{{< /code >}}
 
### ruler_alerts

##### MetricRulerTooManyFailedPushes

{{< code lang="yaml" >}}
alert: MetricRulerTooManyFailedPushes
annotations:
  message: |
    Metric Ruler {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf "%.2f" $value }}% write (push) errors.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrulertoomanyfailedpushes
expr: |
  100 * (
  sum by (cluster, namespace, pod) (rate(cortex_ruler_write_requests_failed_total[1m]))
    /
  sum by (cluster, namespace, pod) (rate(cortex_ruler_write_requests_total[1m]))
  ) > 1
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricRulerTooManyFailedQueries

{{< code lang="yaml" >}}
alert: MetricRulerTooManyFailedQueries
annotations:
  message: |
    Metric Ruler {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf "%.2f" $value }}% errors while evaluating rules.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrulertoomanyfailedqueries
expr: |
  100 * (
  sum by (cluster, namespace, pod) (rate(cortex_ruler_queries_failed_total[1m]))
    /
  sum by (cluster, namespace, pod) (rate(cortex_ruler_queries_total[1m]))
  ) > 1
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricRulerMissedEvaluations

{{< code lang="yaml" >}}
alert: MetricRulerMissedEvaluations
annotations:
  message: |
    Metric Ruler {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is experiencing {{ printf "%.2f" $value }}% missed iterations for the rule group {{ $labels.rule_group }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrulermissedevaluations
expr: |
  100 * (
  sum by (cluster, namespace, pod, rule_group) (rate(cortex_prometheus_rule_group_iterations_missed_total[1m]))
    /
  sum by (cluster, namespace, pod, rule_group) (rate(cortex_prometheus_rule_group_iterations_total[1m]))
  ) > 1
for: 5m
labels:
  severity: warning
{{< /code >}}
 
##### MetricRulerFailedRingCheck

{{< code lang="yaml" >}}
alert: MetricRulerFailedRingCheck
annotations:
  message: |
    Metric Rulers in {{ $labels.cluster }}/{{ $labels.namespace }} are experiencing errors when checking the ring for rule group ownership.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrulerfailedringcheck
expr: |
  sum by (cluster, namespace, job) (rate(cortex_ruler_ring_check_errors_total[1m]))
     > 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricRulerRemoteEvaluationFailing

{{< code lang="yaml" >}}
alert: MetricRulerRemoteEvaluationFailing
annotations:
  message: |
    Metric rulers in {{ $labels.cluster }}/{{ $labels.namespace }} are failing to perform {{ printf "%.2f" $value }}% of remote evaluations through the ruler-query-frontend.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricrulerremoteevaluationfailing
expr: |
  100 * (
  sum by (cluster, namespace) (rate(cortex_request_duration_seconds_count{route="/httpgrpc.HTTP/Handle", status_code=~"5..", job=~".*/(ruler-query-frontend.*)"}[5m]))
    /
  sum by (cluster, namespace) (rate(cortex_request_duration_seconds_count{route="/httpgrpc.HTTP/Handle", job=~".*/(ruler-query-frontend.*)"}[5m]))
  ) > 1
for: 5m
labels:
  severity: warning
{{< /code >}}
 
### gossip_alerts

##### MetricGossipMembersMismatch

{{< code lang="yaml" >}}
alert: MetricGossipMembersMismatch
annotations:
  message: Metric instance {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} sees incorrect number of gossip members.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricgossipmembersmismatch
expr: |
  avg by (cluster, namespace) (memberlist_client_cluster_members_count) != sum by (cluster, namespace) (up{job=~".+/(alertmanager|compactor|distributor|ingester.*|querier.*|ruler|ruler-querier.*|store-gateway.*|cortex|mimir|mimir-write.*|mimir-read.*|mimir-backend.*)"})
for: 15m
labels:
  severity: warning
{{< /code >}}
 
### etcd_alerts

##### EtcdAllocatingTooMuchMemory

{{< code lang="yaml" >}}
alert: EtcdAllocatingTooMuchMemory
annotations:
  message: |
    Too much memory being used by {{ $labels.namespace }}/{{ $labels.pod }} - bump memory limit.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#etcdallocatingtoomuchmemory
expr: |
  (
    container_memory_working_set_bytes{container="etcd"}
      /
    ( container_spec_memory_limit_bytes{container="etcd"} > 0 )
  ) > 0.65
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### EtcdAllocatingTooMuchMemory

{{< code lang="yaml" >}}
alert: EtcdAllocatingTooMuchMemory
annotations:
  message: |
    Too much memory being used by {{ $labels.namespace }}/{{ $labels.pod }} - bump memory limit.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#etcdallocatingtoomuchmemory
expr: |
  (
    container_memory_working_set_bytes{container="etcd"}
      /
    ( container_spec_memory_limit_bytes{container="etcd"} > 0 )
  ) > 0.8
for: 15m
labels:
  severity: critical
{{< /code >}}
 
### alertmanager_alerts

##### MetricAlertmanagerSyncConfigsFailing
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagersyncconfigsfailing

{{< code lang="yaml" >}}
alert: MetricAlertmanagerSyncConfigsFailing
annotations:
  message: |
    Metric Alertmanager {{ $labels.job }}/{{ $labels.pod }} is failing to read tenant configurations from storage.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagersyncconfigsfailing
expr: |
  rate(cortex_alertmanager_sync_configs_failed_total[5m]) > 0
for: 30m
labels:
  severity: critical
{{< /code >}}
 
##### MetricAlertmanagerRingCheckFailing
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerringcheckfailing

{{< code lang="yaml" >}}
alert: MetricAlertmanagerRingCheckFailing
annotations:
  message: |
    Metric Alertmanager {{ $labels.job }}/{{ $labels.pod }} is unable to check tenants ownership via the ring.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerringcheckfailing
expr: |
  rate(cortex_alertmanager_ring_check_errors_total[2m]) > 0
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### MetricAlertmanagerPartialStateMergeFailing
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerpartialstatemergefailing

{{< code lang="yaml" >}}
alert: MetricAlertmanagerPartialStateMergeFailing
annotations:
  message: |
    Metric Alertmanager {{ $labels.job }}/{{ $labels.pod }} is failing to merge partial state changes received from a replica.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerpartialstatemergefailing
expr: |
  rate(cortex_alertmanager_partial_state_merges_failed_total[2m]) > 0
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### MetricAlertmanagerReplicationFailing
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerreplicationfailing

{{< code lang="yaml" >}}
alert: MetricAlertmanagerReplicationFailing
annotations:
  message: |
    Metric Alertmanager {{ $labels.job }}/{{ $labels.pod }} is failing to replicating partial state to its replicas.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerreplicationfailing
expr: |
  rate(cortex_alertmanager_state_replication_failed_total[2m]) > 0
for: 10m
labels:
  severity: critical
{{< /code >}}
 
##### MetricAlertmanagerPersistStateFailing
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerpersiststatefailing

{{< code lang="yaml" >}}
alert: MetricAlertmanagerPersistStateFailing
annotations:
  message: |
    Metric Alertmanager {{ $labels.job }}/{{ $labels.pod }} is unable to persist full state snaphots to remote storage.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerpersiststatefailing
expr: |
  rate(cortex_alertmanager_state_persist_failed_total[15m]) > 0
for: 1h
labels:
  severity: critical
{{< /code >}}
 
##### MetricAlertmanagerInitialSyncFailed
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerinitialsyncfailed

{{< code lang="yaml" >}}
alert: MetricAlertmanagerInitialSyncFailed
annotations:
  message: |
    Metric Alertmanager {{ $labels.job }}/{{ $labels.pod }} was unable to obtain some initial state when starting up.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerinitialsyncfailed
expr: |
  increase(cortex_alertmanager_state_initial_sync_completed_total{outcome="failed"}[1m]) > 0
labels:
  severity: critical
{{< /code >}}
 
##### MetricAlertmanagerAllocatingTooMuchMemory
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerallocatingtoomuchmemory

{{< code lang="yaml" >}}
alert: MetricAlertmanagerAllocatingTooMuchMemory
annotations:
  message: |
    Alertmanager {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is using too much memory.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerallocatingtoomuchmemory
expr: |
  (container_memory_working_set_bytes{container="alertmanager"} / container_spec_memory_limit_bytes{container="alertmanager"}) > 0.80
  and
  (container_spec_memory_limit_bytes{container="alertmanager"} > 0)
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### MetricAlertmanagerAllocatingTooMuchMemory
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerallocatingtoomuchmemory

{{< code lang="yaml" >}}
alert: MetricAlertmanagerAllocatingTooMuchMemory
annotations:
  message: |
    Alertmanager {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace }} is using too much memory.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerallocatingtoomuchmemory
expr: |
  (container_memory_working_set_bytes{container="alertmanager"} / container_spec_memory_limit_bytes{container="alertmanager"}) > 0.90
  and
  (container_spec_memory_limit_bytes{container="alertmanager"} > 0)
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### MetricAlertmanagerInstanceHasNoTenants
Metric alertmanager {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerinstancehasnotenants

{{< code lang="yaml" >}}
alert: MetricAlertmanagerInstanceHasNoTenants
annotations:
  message: Metric alertmanager {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} owns no tenants.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricalertmanagerinstancehasnotenants
expr: |
  # Alert on alertmanager instances in microservices mode that own no tenants,
  min by(cluster, namespace, pod) (cortex_alertmanager_tenants_owned{pod=~"(.*mimir-)?alertmanager.*"}) == 0
  # but only if other instances of the same cell do have tenants assigned.
  and on (cluster, namespace)
  max by(cluster, namespace) (cortex_alertmanager_tenants_owned) > 0
for: 1h
labels:
  severity: warning
{{< /code >}}
 
### mimir_blocks_alerts

##### MetricIngesterHasNotShippedBlocks

{{< code lang="yaml" >}}
alert: MetricIngesterHasNotShippedBlocks
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not shipped any block in the last 4 hours.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterhasnotshippedblocks
expr: |
  (min by(cluster, namespace, pod) (time() - thanos_shipper_last_successful_upload_time) > 60 * 60 * 4)
  and
  (max by(cluster, namespace, pod) (thanos_shipper_last_successful_upload_time) > 0)
  and
  # Only if the ingester has ingested samples over the last 4h.
  (max by(cluster, namespace, pod) (max_over_time(cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m[4h])) > 0)
  and
  # Only if the ingester was ingesting samples 4h ago. This protects against the case where the ingester replica
  # had ingested samples in the past, then no traffic was received for a long period and then it starts
  # receiving samples again. Without this check, the alert would fire as soon as it gets back receiving
  # samples, while the a block shipping is expected within the next 4h.
  (max by(cluster, namespace, pod) (max_over_time(cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m[1h] offset 4h)) > 0)
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterHasNotShippedBlocksSinceStart

{{< code lang="yaml" >}}
alert: MetricIngesterHasNotShippedBlocksSinceStart
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not shipped any block in the last 4 hours.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterhasnotshippedblockssincestart
expr: |
  (max by(cluster, namespace, pod) (thanos_shipper_last_successful_upload_time) == 0)
  and
  (max by(cluster, namespace, pod) (max_over_time(cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m[4h])) > 0)
for: 4h
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterHasUnshippedBlocks

{{< code lang="yaml" >}}
alert: MetricIngesterHasUnshippedBlocks
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has compacted a block {{ $value | humanizeDuration }} ago but it hasn't been
    successfully uploaded to the storage yet.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingesterhasunshippedblocks
expr: |
  (time() - cortex_ingester_oldest_unshipped_block_timestamp_seconds > 3600)
  and
  (cortex_ingester_oldest_unshipped_block_timestamp_seconds > 0)
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterTSDBHeadCompactionFailed

{{< code lang="yaml" >}}
alert: MetricIngesterTSDBHeadCompactionFailed
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is failing to compact TSDB head.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingestertsdbheadcompactionfailed
expr: |
  rate(cortex_ingester_tsdb_compactions_failed_total[5m]) > 0
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterTSDBHeadTruncationFailed

{{< code lang="yaml" >}}
alert: MetricIngesterTSDBHeadTruncationFailed
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is failing to truncate TSDB head.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingestertsdbheadtruncationfailed
expr: |
  rate(cortex_ingester_tsdb_head_truncations_failed_total[5m]) > 0
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterTSDBCheckpointCreationFailed

{{< code lang="yaml" >}}
alert: MetricIngesterTSDBCheckpointCreationFailed
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is failing to create TSDB checkpoint.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingestertsdbcheckpointcreationfailed
expr: |
  rate(cortex_ingester_tsdb_checkpoint_creations_failed_total[5m]) > 0
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterTSDBCheckpointDeletionFailed

{{< code lang="yaml" >}}
alert: MetricIngesterTSDBCheckpointDeletionFailed
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is failing to delete TSDB checkpoint.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingestertsdbcheckpointdeletionfailed
expr: |
  rate(cortex_ingester_tsdb_checkpoint_deletions_failed_total[5m]) > 0
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterTSDBWALTruncationFailed

{{< code lang="yaml" >}}
alert: MetricIngesterTSDBWALTruncationFailed
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is failing to truncate TSDB WAL.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingestertsdbwaltruncationfailed
expr: |
  rate(cortex_ingester_tsdb_wal_truncations_failed_total[5m]) > 0
labels:
  severity: warning
{{< /code >}}
 
##### MetricIngesterTSDBWALCorrupted

{{< code lang="yaml" >}}
alert: MetricIngesterTSDBWALCorrupted
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} got a corrupted TSDB WAL.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingestertsdbwalcorrupted
expr: |
  rate(cortex_ingester_tsdb_wal_corruptions_total[5m]) > 0
labels:
  severity: critical
{{< /code >}}
 
##### MetricIngesterTSDBWALWritesFailed

{{< code lang="yaml" >}}
alert: MetricIngesterTSDBWALWritesFailed
annotations:
  message: Metric Ingester {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is failing to write to TSDB WAL.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricingestertsdbwalwritesfailed
expr: |
  rate(cortex_ingester_tsdb_wal_writes_failed_total[1m]) > 0
for: 3m
labels:
  severity: critical
{{< /code >}}
 
##### MetricQuerierHasNotScanTheBucket

{{< code lang="yaml" >}}
alert: MetricQuerierHasNotScanTheBucket
annotations:
  message: Metric Querier {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not successfully scanned the bucket since {{ $value | humanizeDuration
    }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricquerierhasnotscanthebucket
expr: |
  (time() - cortex_querier_blocks_last_successful_scan_timestamp_seconds > 60 * 30)
  and
  cortex_querier_blocks_last_successful_scan_timestamp_seconds > 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricQuerierHighRefetchRate

{{< code lang="yaml" >}}
alert: MetricQuerierHighRefetchRate
annotations:
  message: Metric Queries in {{ $labels.cluster }}/{{ $labels.namespace }} are refetching
    series from different store-gateways (because of missing blocks) for the {{ printf
    "%.0f" $value }}% of queries.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricquerierhighrefetchrate
expr: |
  100 * (
    (
      sum by(cluster, namespace) (rate(cortex_querier_storegateway_refetches_per_query_count[5m]))
      -
      sum by(cluster, namespace) (rate(cortex_querier_storegateway_refetches_per_query_bucket{le="0.0"}[5m]))
    )
    /
    sum by(cluster, namespace) (rate(cortex_querier_storegateway_refetches_per_query_count[5m]))
  )
  > 1
for: 10m
labels:
  severity: warning
{{< /code >}}
 
##### MetricStoreGatewayHasNotSyncTheBucket

{{< code lang="yaml" >}}
alert: MetricStoreGatewayHasNotSyncTheBucket
annotations:
  message: Metric store-gateway {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not successfully synched the bucket since {{ $value | humanizeDuration
    }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricstoregatewayhasnotsyncthebucket
expr: |
  (time() - cortex_bucket_stores_blocks_last_successful_sync_timestamp_seconds{component="store-gateway"} > 60 * 30)
  and
  cortex_bucket_stores_blocks_last_successful_sync_timestamp_seconds{component="store-gateway"} > 0
for: 5m
labels:
  severity: critical
{{< /code >}}
 
##### MetricStoreGatewayNoSyncedTenants

{{< code lang="yaml" >}}
alert: MetricStoreGatewayNoSyncedTenants
annotations:
  message: Metric store-gateway {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is not syncing any blocks for any tenant.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricstoregatewaynosyncedtenants
expr: |
  min by(cluster, namespace, pod) (cortex_bucket_stores_tenants_synced{component="store-gateway"}) == 0
for: 1h
labels:
  severity: warning
{{< /code >}}
 
##### MetricBucketIndexNotUpdated

{{< code lang="yaml" >}}
alert: MetricBucketIndexNotUpdated
annotations:
  message: Metric bucket index for tenant {{ $labels.user }} in {{ $labels.cluster
    }}/{{ $labels.namespace }} has not been updated since {{ $value | humanizeDuration
    }}.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricbucketindexnotupdated
expr: |
  min by(cluster, namespace, user) (time() - cortex_bucket_index_last_successful_update_timestamp_seconds) > 7200
labels:
  severity: critical
{{< /code >}}
 
##### MetricTenantHasPartialBlocks

{{< code lang="yaml" >}}
alert: MetricTenantHasPartialBlocks
annotations:
  message: Metric tenant {{ $labels.user }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has {{ $value }} partial blocks.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metrictenanthaspartialblocks
expr: |
  max by(cluster, namespace, user) (cortex_bucket_blocks_partials_count) > 0
for: 6h
labels:
  severity: warning
{{< /code >}}
 
### mimir_compactor_alerts

##### MetricCompactorHasNotSuccessfullyCleanedUpBlocks

{{< code lang="yaml" >}}
alert: MetricCompactorHasNotSuccessfullyCleanedUpBlocks
annotations:
  message: Metric Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not successfully cleaned up blocks in the last 6 hours.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccompactorhasnotsuccessfullycleanedupblocks
expr: |
  # The "last successful run" metric is updated even if the compactor owns no tenants,
  # so this alert correctly doesn't fire if compactor has nothing to do.
  (time() - cortex_compactor_block_cleanup_last_successful_run_timestamp_seconds > 60 * 60 * 6)
for: 1h
labels:
  severity: critical
{{< /code >}}
 
##### MetricCompactorHasNotSuccessfullyRunCompaction

{{< code lang="yaml" >}}
alert: MetricCompactorHasNotSuccessfullyRunCompaction
annotations:
  message: Metric Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not run compaction in the last 24 hours.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccompactorhasnotsuccessfullyruncompaction
expr: |
  # The "last successful run" metric is updated even if the compactor owns no tenants,
  # so this alert correctly doesn't fire if compactor has nothing to do.
  (time() - cortex_compactor_last_successful_run_timestamp_seconds > 60 * 60 * 24)
  and
  (cortex_compactor_last_successful_run_timestamp_seconds > 0)
for: 1h
labels:
  reason: in-last-24h
  severity: critical
{{< /code >}}
 
##### MetricCompactorHasNotSuccessfullyRunCompaction

{{< code lang="yaml" >}}
alert: MetricCompactorHasNotSuccessfullyRunCompaction
annotations:
  message: Metric Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not run compaction in the last 24 hours.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccompactorhasnotsuccessfullyruncompaction
expr: |
  # The "last successful run" metric is updated even if the compactor owns no tenants,
  # so this alert correctly doesn't fire if compactor has nothing to do.
  cortex_compactor_last_successful_run_timestamp_seconds == 0
for: 24h
labels:
  reason: since-startup
  severity: critical
{{< /code >}}
 
##### MetricCompactorHasNotSuccessfullyRunCompaction

{{< code lang="yaml" >}}
alert: MetricCompactorHasNotSuccessfullyRunCompaction
annotations:
  message: Metric Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} failed to run 2 consecutive compactions.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccompactorhasnotsuccessfullyruncompaction
expr: |
  increase(cortex_compactor_runs_failed_total{reason!="shutdown"}[2h]) >= 2
labels:
  reason: consecutive-failures
  severity: critical
{{< /code >}}
 
##### MetricCompactorHasNotUploadedBlocks

{{< code lang="yaml" >}}
alert: MetricCompactorHasNotUploadedBlocks
annotations:
  message: Metric Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not uploaded any block in the last 24 hours.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccompactorhasnotuploadedblocks
expr: |
  (time() - (max by(cluster, namespace, pod) (thanos_objstore_bucket_last_successful_upload_time{component="compactor"})) > 60 * 60 * 24)
  and
  (max by(cluster, namespace, pod) (thanos_objstore_bucket_last_successful_upload_time{component="compactor"}) > 0)
  and
  # Only if some compactions have started. We don't want to fire this alert if the compactor has nothing to do
  # (e.g. there are more replicas than required because running as part of mimir-backend).
  (sum by(cluster, namespace, pod) (rate(cortex_compactor_group_compaction_runs_started_total[24h])) > 0)
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### MetricCompactorHasNotUploadedBlocks

{{< code lang="yaml" >}}
alert: MetricCompactorHasNotUploadedBlocks
annotations:
  message: Metric Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has not uploaded any block in the last 24 hours.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccompactorhasnotuploadedblocks
expr: |
  (max by(cluster, namespace, pod) (thanos_objstore_bucket_last_successful_upload_time{component="compactor"}) == 0)
  and
  # Only if some compactions have started. We don't want to fire this alert if the compactor has nothing to do
  # (e.g. there are more replicas than required because running as part of mimir-backend).
  (sum by(cluster, namespace, pod) (rate(cortex_compactor_group_compaction_runs_started_total[24h])) > 0)
for: 24h
labels:
  severity: critical
{{< /code >}}
 
##### MetricCompactorSkippedBlocksWithOutOfOrderChunks

{{< code lang="yaml" >}}
alert: MetricCompactorSkippedBlocksWithOutOfOrderChunks
annotations:
  message: Metric Compactor {{ $labels.pod }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} has found and ignored blocks with out of order chunks.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccompactorskippedblockswithoutoforderchunks
expr: |
  increase(cortex_compactor_blocks_marked_for_no_compaction_total{reason="block-index-out-of-order-chunk"}[5m]) > 0
for: 1m
labels:
  severity: warning
{{< /code >}}
 
### mimir_autoscaling

##### MetricAutoscalerNotActive

{{< code lang="yaml" >}}
alert: MetricAutoscalerNotActive
annotations:
  message: The Horizontal Pod Autoscaler (HPA) {{ $labels.horizontalpodautoscaler
    }} in {{ $labels.namespace }} is not active.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricautoscalernotactive
expr: |
  (
      kube_horizontalpodautoscaler_status_condition{condition="ScalingActive",status="false"}
      # Match only Mimir namespaces.
      * on(cluster, namespace) group_left max by(cluster, namespace) (cortex_build_info)
      # Add "metric" label.
      + on(cluster, namespace, horizontalpodautoscaler) group_right label_replace(kube_horizontalpodautoscaler_spec_target_metric*0, "metric", "$1", "metric_name", "(.+)")
      > 0
  )
  # Alert only if the scaling metric exists and is > 0. If the KEDA ScaledObject is configured to scale down 0,
  # then HPA ScalingActive may be false when expected to run 0 replicas. In this case, the scaling metric exported
  # by KEDA could not exist at all or being exposed with a value of 0.
  and on (cluster, namespace, metric)
  (label_replace(keda_metrics_adapter_scaler_metrics_value, "namespace", "$0", "exported_namespace", ".+") > 0)
for: 1h
labels:
  severity: critical
{{< /code >}}
 
##### MetricAutoscalerKedaFailing

{{< code lang="yaml" >}}
alert: MetricAutoscalerKedaFailing
annotations:
  message: The Keda ScaledObject {{ $labels.scaledObject }} in {{ $labels.namespace
    }} is experiencing errors.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metricautoscalerkedafailing
expr: |
  (
      # Find KEDA scalers reporting errors.
      label_replace(rate(keda_metrics_adapter_scaler_errors[5m]), "namespace", "$1", "exported_namespace", "(.*)")
      # Match only Mimir namespaces.
      * on(cluster, namespace) group_left max by(cluster, namespace) (cortex_build_info)
  )
  > 0
for: 1h
labels:
  severity: critical
{{< /code >}}
 
### mimir_continuous_test

##### MetricContinuousTestNotRunningOnWrites

{{< code lang="yaml" >}}
alert: MetricContinuousTestNotRunningOnWrites
annotations:
  message: Metric continuous test {{ $labels.test }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is not effectively running because writes are failing.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccontinuoustestnotrunningonwrites
expr: |
  sum by(cluster, namespace, test) (rate(mimir_continuous_test_writes_failed_total[5m])) > 0
for: 1h
labels:
  severity: warning
{{< /code >}}
 
##### MetricContinuousTestNotRunningOnReads

{{< code lang="yaml" >}}
alert: MetricContinuousTestNotRunningOnReads
annotations:
  message: Metric continuous test {{ $labels.test }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} is not effectively running because queries are failing.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccontinuoustestnotrunningonreads
expr: |
  sum by(cluster, namespace, test) (rate(mimir_continuous_test_queries_failed_total[5m])) > 0
for: 1h
labels:
  severity: warning
{{< /code >}}
 
##### MetricContinuousTestFailed

{{< code lang="yaml" >}}
alert: MetricContinuousTestFailed
annotations:
  message: Metric continuous test {{ $labels.test }} in {{ $labels.cluster }}/{{ $labels.namespace
    }} failed when asserting query results.
  runbook_url: https://grafana.com/docs/mimir/latest/operators-guide/mimir-runbooks/#metriccontinuoustestfailed
expr: |
  sum by(cluster, namespace, test) (rate(mimir_continuous_test_query_result_checks_failed_total[10m])) > 0
labels:
  severity: warning
{{< /code >}}
 
## Recording rules

{{< panel style="warning" >}}
Complete list of pregenerated recording rules is available [here](https://github.com/observeproject/sites/blob/main/assets/mimir/rules.yaml).
{{< /panel >}}

### mimir_api_1

##### cluster_job:cortex_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_request_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job:cortex_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_request_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job:cortex_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, job) / sum(rate(cortex_request_duration_seconds_count[1m]))
  by (cluster, job)
record: cluster_job:cortex_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_job:cortex_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, job)
record: cluster_job:cortex_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, job)
record: cluster_job:cortex_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, job)
record: cluster_job:cortex_request_duration_seconds_count:sum_rate
{{< /code >}}
 
### mimir_api_2

##### cluster_job_route:cortex_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_request_duration_seconds_bucket[1m]))
  by (le, cluster, job, route))
record: cluster_job_route:cortex_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job_route:cortex_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_request_duration_seconds_bucket[1m]))
  by (le, cluster, job, route))
record: cluster_job_route:cortex_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job_route:cortex_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, job, route)
  / sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, job, route)
record: cluster_job_route:cortex_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_job_route:cortex_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, job,
  route)
record: cluster_job_route:cortex_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job_route:cortex_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, job, route)
record: cluster_job_route:cortex_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job_route:cortex_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, job, route)
record: cluster_job_route:cortex_request_duration_seconds_count:sum_rate
{{< /code >}}
 
### mimir_api_3

##### cluster_namespace_job_route:cortex_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_request_duration_seconds_bucket[1m]))
  by (le, cluster, namespace, job, route))
record: cluster_namespace_job_route:cortex_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_request_duration_seconds_bucket[1m]))
  by (le, cluster, namespace, job, route))
record: cluster_namespace_job_route:cortex_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, namespace, job,
  route) / sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, namespace,
  job, route)
record: cluster_namespace_job_route:cortex_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_bucket[1m])) by (le, cluster, namespace,
  job, route)
record: cluster_namespace_job_route:cortex_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_sum[1m])) by (cluster, namespace, job,
  route)
record: cluster_namespace_job_route:cortex_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_request_duration_seconds_count[1m])) by (cluster, namespace,
  job, route)
record: cluster_namespace_job_route:cortex_request_duration_seconds_count:sum_rate
{{< /code >}}
 
### mimir_querier_api

##### cluster_job:cortex_querier_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_querier_request_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_querier_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job:cortex_querier_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_querier_request_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_querier_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job:cortex_querier_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, job)
  / sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, job)
record: cluster_job:cortex_querier_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_job:cortex_querier_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster,
  job)
record: cluster_job:cortex_querier_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_querier_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, job)
record: cluster_job:cortex_querier_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_querier_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, job)
record: cluster_job:cortex_querier_request_duration_seconds_count:sum_rate
{{< /code >}}
 
##### cluster_job_route:cortex_querier_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_querier_request_duration_seconds_bucket[1m]))
  by (le, cluster, job, route))
record: cluster_job_route:cortex_querier_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job_route:cortex_querier_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_querier_request_duration_seconds_bucket[1m]))
  by (le, cluster, job, route))
record: cluster_job_route:cortex_querier_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job_route:cortex_querier_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, job,
  route) / sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster,
  job, route)
record: cluster_job_route:cortex_querier_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_job_route:cortex_querier_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster,
  job, route)
record: cluster_job_route:cortex_querier_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job_route:cortex_querier_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, job,
  route)
record: cluster_job_route:cortex_querier_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job_route:cortex_querier_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, job,
  route)
record: cluster_job_route:cortex_querier_request_duration_seconds_count:sum_rate
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_querier_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_querier_request_duration_seconds_bucket[1m]))
  by (le, cluster, namespace, job, route))
record: cluster_namespace_job_route:cortex_querier_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_querier_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_querier_request_duration_seconds_bucket[1m]))
  by (le, cluster, namespace, job, route))
record: cluster_namespace_job_route:cortex_querier_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_querier_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, namespace,
  job, route) / sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster,
  namespace, job, route)
record: cluster_namespace_job_route:cortex_querier_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_querier_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_bucket[1m])) by (le, cluster,
  namespace, job, route)
record: cluster_namespace_job_route:cortex_querier_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_querier_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_sum[1m])) by (cluster, namespace,
  job, route)
record: cluster_namespace_job_route:cortex_querier_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_namespace_job_route:cortex_querier_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_querier_request_duration_seconds_count[1m])) by (cluster, namespace,
  job, route)
record: cluster_namespace_job_route:cortex_querier_request_duration_seconds_count:sum_rate
{{< /code >}}
 
### mimir_cache

##### cluster_job_method:cortex_memcache_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_memcache_request_duration_seconds_bucket[1m]))
  by (le, cluster, job, method))
record: cluster_job_method:cortex_memcache_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job_method:cortex_memcache_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_memcache_request_duration_seconds_bucket[1m]))
  by (le, cluster, job, method))
record: cluster_job_method:cortex_memcache_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job_method:cortex_memcache_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_memcache_request_duration_seconds_sum[1m])) by (cluster, job,
  method) / sum(rate(cortex_memcache_request_duration_seconds_count[1m])) by (cluster,
  job, method)
record: cluster_job_method:cortex_memcache_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_job_method:cortex_memcache_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_memcache_request_duration_seconds_bucket[1m])) by (le, cluster,
  job, method)
record: cluster_job_method:cortex_memcache_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job_method:cortex_memcache_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_memcache_request_duration_seconds_sum[1m])) by (cluster, job,
  method)
record: cluster_job_method:cortex_memcache_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job_method:cortex_memcache_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_memcache_request_duration_seconds_count[1m])) by (cluster, job,
  method)
record: cluster_job_method:cortex_memcache_request_duration_seconds_count:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_cache_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_cache_request_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_cache_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job:cortex_cache_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_cache_request_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_cache_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job:cortex_cache_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_cache_request_duration_seconds_sum[1m])) by (cluster, job) /
  sum(rate(cortex_cache_request_duration_seconds_count[1m])) by (cluster, job)
record: cluster_job:cortex_cache_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_job:cortex_cache_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_cache_request_duration_seconds_bucket[1m])) by (le, cluster,
  job)
record: cluster_job:cortex_cache_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_cache_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_cache_request_duration_seconds_sum[1m])) by (cluster, job)
record: cluster_job:cortex_cache_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_cache_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_cache_request_duration_seconds_count[1m])) by (cluster, job)
record: cluster_job:cortex_cache_request_duration_seconds_count:sum_rate
{{< /code >}}
 
##### cluster_job_method:cortex_cache_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_cache_request_duration_seconds_bucket[1m]))
  by (le, cluster, job, method))
record: cluster_job_method:cortex_cache_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job_method:cortex_cache_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_cache_request_duration_seconds_bucket[1m]))
  by (le, cluster, job, method))
record: cluster_job_method:cortex_cache_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job_method:cortex_cache_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_cache_request_duration_seconds_sum[1m])) by (cluster, job, method)
  / sum(rate(cortex_cache_request_duration_seconds_count[1m])) by (cluster, job, method)
record: cluster_job_method:cortex_cache_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_job_method:cortex_cache_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_cache_request_duration_seconds_bucket[1m])) by (le, cluster,
  job, method)
record: cluster_job_method:cortex_cache_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job_method:cortex_cache_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_cache_request_duration_seconds_sum[1m])) by (cluster, job, method)
record: cluster_job_method:cortex_cache_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job_method:cortex_cache_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_cache_request_duration_seconds_count[1m])) by (cluster, job,
  method)
record: cluster_job_method:cortex_cache_request_duration_seconds_count:sum_rate
{{< /code >}}
 
### mimir_storage

##### cluster_job:cortex_kv_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_kv_request_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_kv_request_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job:cortex_kv_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_kv_request_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_kv_request_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job:cortex_kv_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_kv_request_duration_seconds_sum[1m])) by (cluster, job) / sum(rate(cortex_kv_request_duration_seconds_count[1m]))
  by (cluster, job)
record: cluster_job:cortex_kv_request_duration_seconds:avg
{{< /code >}}
 
##### cluster_job:cortex_kv_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_kv_request_duration_seconds_bucket[1m])) by (le, cluster, job)
record: cluster_job:cortex_kv_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_kv_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_kv_request_duration_seconds_sum[1m])) by (cluster, job)
record: cluster_job:cortex_kv_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_kv_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_kv_request_duration_seconds_count[1m])) by (cluster, job)
record: cluster_job:cortex_kv_request_duration_seconds_count:sum_rate
{{< /code >}}
 
### mimir_queries

##### cluster_job:cortex_query_frontend_retries:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_query_frontend_retries_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_query_frontend_retries:99quantile
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_retries:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_query_frontend_retries_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_query_frontend_retries:50quantile
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_retries:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_query_frontend_retries_sum[1m])) by (cluster, job) / sum(rate(cortex_query_frontend_retries_count[1m]))
  by (cluster, job)
record: cluster_job:cortex_query_frontend_retries:avg
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_retries_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_query_frontend_retries_bucket[1m])) by (le, cluster, job)
record: cluster_job:cortex_query_frontend_retries_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_retries_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_query_frontend_retries_sum[1m])) by (cluster, job)
record: cluster_job:cortex_query_frontend_retries_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_retries_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_query_frontend_retries_count[1m])) by (cluster, job)
record: cluster_job:cortex_query_frontend_retries_count:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_queue_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_query_frontend_queue_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_query_frontend_queue_duration_seconds:99quantile
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_queue_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_query_frontend_queue_duration_seconds_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_query_frontend_queue_duration_seconds:50quantile
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_queue_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_query_frontend_queue_duration_seconds_sum[1m])) by (cluster,
  job) / sum(rate(cortex_query_frontend_queue_duration_seconds_count[1m])) by (cluster,
  job)
record: cluster_job:cortex_query_frontend_queue_duration_seconds:avg
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_queue_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_query_frontend_queue_duration_seconds_bucket[1m])) by (le, cluster,
  job)
record: cluster_job:cortex_query_frontend_queue_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_queue_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_query_frontend_queue_duration_seconds_sum[1m])) by (cluster,
  job)
record: cluster_job:cortex_query_frontend_queue_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_query_frontend_queue_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_query_frontend_queue_duration_seconds_count[1m])) by (cluster,
  job)
record: cluster_job:cortex_query_frontend_queue_duration_seconds_count:sum_rate
{{< /code >}}
 
### mimir_ingester_queries

##### cluster_job:cortex_ingester_queried_series:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_ingester_queried_series_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_ingester_queried_series:99quantile
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_series:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_ingester_queried_series_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_ingester_queried_series:50quantile
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_series:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_series_sum[1m])) by (cluster, job) / sum(rate(cortex_ingester_queried_series_count[1m]))
  by (cluster, job)
record: cluster_job:cortex_ingester_queried_series:avg
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_series_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_series_bucket[1m])) by (le, cluster, job)
record: cluster_job:cortex_ingester_queried_series_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_series_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_series_sum[1m])) by (cluster, job)
record: cluster_job:cortex_ingester_queried_series_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_series_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_series_count[1m])) by (cluster, job)
record: cluster_job:cortex_ingester_queried_series_count:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_samples:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_ingester_queried_samples_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_ingester_queried_samples:99quantile
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_samples:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_ingester_queried_samples_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_ingester_queried_samples:50quantile
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_samples:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_samples_sum[1m])) by (cluster, job) / sum(rate(cortex_ingester_queried_samples_count[1m]))
  by (cluster, job)
record: cluster_job:cortex_ingester_queried_samples:avg
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_samples_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_samples_bucket[1m])) by (le, cluster, job)
record: cluster_job:cortex_ingester_queried_samples_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_samples_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_samples_sum[1m])) by (cluster, job)
record: cluster_job:cortex_ingester_queried_samples_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_samples_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_samples_count[1m])) by (cluster, job)
record: cluster_job:cortex_ingester_queried_samples_count:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_exemplars:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(cortex_ingester_queried_exemplars_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_ingester_queried_exemplars:99quantile
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_exemplars:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(cortex_ingester_queried_exemplars_bucket[1m]))
  by (le, cluster, job))
record: cluster_job:cortex_ingester_queried_exemplars:50quantile
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_exemplars:avg

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_exemplars_sum[1m])) by (cluster, job) / sum(rate(cortex_ingester_queried_exemplars_count[1m]))
  by (cluster, job)
record: cluster_job:cortex_ingester_queried_exemplars:avg
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_exemplars_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_exemplars_bucket[1m])) by (le, cluster, job)
record: cluster_job:cortex_ingester_queried_exemplars_bucket:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_exemplars_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_exemplars_sum[1m])) by (cluster, job)
record: cluster_job:cortex_ingester_queried_exemplars_sum:sum_rate
{{< /code >}}
 
##### cluster_job:cortex_ingester_queried_exemplars_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(cortex_ingester_queried_exemplars_count[1m])) by (cluster, job)
record: cluster_job:cortex_ingester_queried_exemplars_count:sum_rate
{{< /code >}}
 
### mimir_received_samples

##### cluster_namespace_job:cortex_distributor_received_samples:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, namespace, job) (rate(cortex_distributor_received_samples_total[5m]))
record: cluster_namespace_job:cortex_distributor_received_samples:rate5m
{{< /code >}}
 
### mimir_exemplars_in

##### cluster_namespace_job:cortex_distributor_exemplars_in:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, namespace, job) (rate(cortex_distributor_exemplars_in_total[5m]))
record: cluster_namespace_job:cortex_distributor_exemplars_in:rate5m
{{< /code >}}
 
### mimir_received_exemplars

##### cluster_namespace_job:cortex_distributor_received_exemplars:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, namespace, job) (rate(cortex_distributor_received_exemplars_total[5m]))
record: cluster_namespace_job:cortex_distributor_received_exemplars:rate5m
{{< /code >}}
 
### mimir_exemplars_ingested

##### cluster_namespace_job:cortex_ingester_ingested_exemplars:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, namespace, job) (rate(cortex_ingester_ingested_exemplars_total[5m]))
record: cluster_namespace_job:cortex_ingester_ingested_exemplars:rate5m
{{< /code >}}
 
### mimir_exemplars_appended

##### cluster_namespace_job:cortex_ingester_tsdb_exemplar_exemplars_appended:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, namespace, job) (rate(cortex_ingester_tsdb_exemplar_exemplars_appended_total[5m]))
record: cluster_namespace_job:cortex_ingester_tsdb_exemplar_exemplars_appended:rate5m
{{< /code >}}
 
### mimir_scaling_rules

##### cluster_namespace_deployment:actual_replicas:count

{{< code lang="yaml" >}}
expr: |
  # Convenience rule to get the number of replicas for both a deployment and a statefulset.
  # Multi-zone deployments are grouped together removing the "zone-X" suffix.
  sum by (cluster, namespace, deployment) (
    label_replace(
      kube_deployment_spec_replicas,
      # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
      # always matches everything and the (optional) zone is not removed.
      "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
    )
  )
  or
  sum by (cluster, namespace, deployment) (
    label_replace(kube_statefulset_replicas, "deployment", "$1", "statefulset", "(.*?)(?:-zone-[a-z])?")
  )
record: cluster_namespace_deployment:actual_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  ceil(
    quantile_over_time(0.99,
      sum by (cluster, namespace) (
        cluster_namespace_job:cortex_distributor_received_samples:rate5m
      )[24h:]
    )
    / 240000
  )
labels:
  deployment: distributor
  reason: sample_rate
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  ceil(
    sum by (cluster, namespace) (cortex_limits_overrides{limit_name="ingestion_rate"})
    * 0.59999999999999998 / 240000
  )
labels:
  deployment: distributor
  reason: sample_rate_limits
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  ceil(
    quantile_over_time(0.99,
      sum by (cluster, namespace) (
        cluster_namespace_job:cortex_distributor_received_samples:rate5m
      )[24h:]
    )
    * 3 / 80000
  )
labels:
  deployment: ingester
  reason: sample_rate
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  ceil(
    quantile_over_time(0.99,
      sum by(cluster, namespace) (
        cortex_ingester_memory_series
      )[24h:]
    )
    / 1500000
  )
labels:
  deployment: ingester
  reason: active_series
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  ceil(
    sum by (cluster, namespace) (cortex_limits_overrides{limit_name="max_global_series_per_user"})
    * 3 * 0.59999999999999998 / 1500000
  )
labels:
  deployment: ingester
  reason: active_series_limits
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  ceil(
    sum by (cluster, namespace) (cortex_limits_overrides{limit_name="ingestion_rate"})
    * 0.59999999999999998 / 80000
  )
labels:
  deployment: ingester
  reason: sample_rate_limits
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  ceil(
    (sum by (cluster, namespace) (
      cortex_ingester_tsdb_storage_blocks_bytes{job=~".+/ingester.*"}
    ) / 4)
      /
    avg by (cluster, namespace) (
      memcached_limit_bytes{job=~".+/memcached"}
    )
  )
labels:
  deployment: memcached
  reason: active_series
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment:container_cpu_usage_seconds_total:sum_rate

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, namespace, deployment) (
    label_replace(
      label_replace(
        node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate,
        "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
      ),
      # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
      # always matches everything and the (optional) zone is not removed.
      "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
    )
  )
record: cluster_namespace_deployment:container_cpu_usage_seconds_total:sum_rate
{{< /code >}}
 
##### 
cluster_namespace_deployment:kube_pod_container_resource_requests_cpu_cores:sum

{{< code lang="yaml" >}}
expr: |
  # Convenience rule to get the CPU request for both a deployment and a statefulset.
  # Multi-zone deployments are grouped together removing the "zone-X" suffix.
  # This recording rule is made compatible with the breaking changes introduced in kube-state-metrics v2
  # that remove resource metrics, ref:
  # - https://github.com/kubernetes/kube-state-metrics/blob/master/CHANGELOG.md#v200-alpha--2020-09-16
  # - https://github.com/kubernetes/kube-state-metrics/pull/1004
  #
  # This is the old expression, compatible with kube-state-metrics < v2.0.0,
  # where kube_pod_container_resource_requests_cpu_cores was removed:
  (
    sum by (cluster, namespace, deployment) (
      label_replace(
        label_replace(
          kube_pod_container_resource_requests_cpu_cores,
          "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
        ),
        # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
        # always matches everything and the (optional) zone is not removed.
        "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
      )
    )
  )
  or
  # This expression is compatible with kube-state-metrics >= v1.4.0,
  # where kube_pod_container_resource_requests was introduced.
  (
    sum by (cluster, namespace, deployment) (
      label_replace(
        label_replace(
          kube_pod_container_resource_requests{resource="cpu"},
          "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
        ),
        # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
        # always matches everything and the (optional) zone is not removed.
        "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
      )
    )
  )
record: cluster_namespace_deployment:kube_pod_container_resource_requests_cpu_cores:sum
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  # Jobs should be sized to their CPU usage.
  # We do this by comparing 99th percentile usage over the last 24hrs to
  # their current provisioned #replicas and resource requests.
  ceil(
    cluster_namespace_deployment:actual_replicas:count
      *
    quantile_over_time(0.99, cluster_namespace_deployment:container_cpu_usage_seconds_total:sum_rate[24h])
      /
    cluster_namespace_deployment:kube_pod_container_resource_requests_cpu_cores:sum
  )
labels:
  reason: cpu_usage
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
##### cluster_namespace_deployment:container_memory_usage_bytes:sum

{{< code lang="yaml" >}}
expr: |
  # Convenience rule to get the Memory utilization for both a deployment and a statefulset.
  # Multi-zone deployments are grouped together removing the "zone-X" suffix.
  sum by (cluster, namespace, deployment) (
    label_replace(
      label_replace(
        container_memory_usage_bytes{image!=""},
        "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
      ),
      # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
      # always matches everything and the (optional) zone is not removed.
      "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
    )
  )
record: cluster_namespace_deployment:container_memory_usage_bytes:sum
{{< /code >}}
 
##### 
cluster_namespace_deployment:kube_pod_container_resource_requests_memory_bytes:sum

{{< code lang="yaml" >}}
expr: |
  # Convenience rule to get the Memory request for both a deployment and a statefulset.
  # Multi-zone deployments are grouped together removing the "zone-X" suffix.
  # This recording rule is made compatible with the breaking changes introduced in kube-state-metrics v2
  # that remove resource metrics, ref:
  # - https://github.com/kubernetes/kube-state-metrics/blob/master/CHANGELOG.md#v200-alpha--2020-09-16
  # - https://github.com/kubernetes/kube-state-metrics/pull/1004
  #
  # This is the old expression, compatible with kube-state-metrics < v2.0.0,
  # where kube_pod_container_resource_requests_memory_bytes was removed:
  (
    sum by (cluster, namespace, deployment) (
      label_replace(
        label_replace(
          kube_pod_container_resource_requests_memory_bytes,
          "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
        ),
        # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
        # always matches everything and the (optional) zone is not removed.
        "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
      )
    )
  )
  or
  # This expression is compatible with kube-state-metrics >= v1.4.0,
  # where kube_pod_container_resource_requests was introduced.
  (
    sum by (cluster, namespace, deployment) (
      label_replace(
        label_replace(
          kube_pod_container_resource_requests{resource="memory"},
          "deployment", "$1", "pod", "(.*)-(?:([0-9]+)|([a-z0-9]+)-([a-z0-9]+))"
        ),
        # The question mark in "(.*?)" is used to make it non-greedy, otherwise it
        # always matches everything and the (optional) zone is not removed.
        "deployment", "$1", "deployment", "(.*?)(?:-zone-[a-z])?"
      )
    )
  )
record: cluster_namespace_deployment:kube_pod_container_resource_requests_memory_bytes:sum
{{< /code >}}
 
##### cluster_namespace_deployment_reason:required_replicas:count

{{< code lang="yaml" >}}
expr: |
  # Jobs should be sized to their Memory usage.
  # We do this by comparing 99th percentile usage over the last 24hrs to
  # their current provisioned #replicas and resource requests.
  ceil(
    cluster_namespace_deployment:actual_replicas:count
      *
    quantile_over_time(0.99, cluster_namespace_deployment:container_memory_usage_bytes:sum[24h])
      /
    cluster_namespace_deployment:kube_pod_container_resource_requests_memory_bytes:sum
  )
labels:
  reason: memory_usage
record: cluster_namespace_deployment_reason:required_replicas:count
{{< /code >}}
 
### mimir_alertmanager_rules

##### cluster_job_pod:cortex_alertmanager_alerts:sum

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job, pod) (cortex_alertmanager_alerts)
record: cluster_job_pod:cortex_alertmanager_alerts:sum
{{< /code >}}
 
##### cluster_job_pod:cortex_alertmanager_silences:sum

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job, pod) (cortex_alertmanager_silences)
record: cluster_job_pod:cortex_alertmanager_silences:sum
{{< /code >}}
 
##### cluster_job:cortex_alertmanager_alerts_received_total:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job) (rate(cortex_alertmanager_alerts_received_total[5m]))
record: cluster_job:cortex_alertmanager_alerts_received_total:rate5m
{{< /code >}}
 
##### cluster_job:cortex_alertmanager_alerts_invalid_total:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job) (rate(cortex_alertmanager_alerts_invalid_total[5m]))
record: cluster_job:cortex_alertmanager_alerts_invalid_total:rate5m
{{< /code >}}
 
##### cluster_job_integration:cortex_alertmanager_notifications_total:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job, integration) (rate(cortex_alertmanager_notifications_total[5m]))
record: cluster_job_integration:cortex_alertmanager_notifications_total:rate5m
{{< /code >}}
 
##### cluster_job_integration:cortex_alertmanager_notifications_failed_total:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job, integration) (rate(cortex_alertmanager_notifications_failed_total[5m]))
record: cluster_job_integration:cortex_alertmanager_notifications_failed_total:rate5m
{{< /code >}}
 
##### cluster_job:cortex_alertmanager_state_replication_total:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job) (rate(cortex_alertmanager_state_replication_total[5m]))
record: cluster_job:cortex_alertmanager_state_replication_total:rate5m
{{< /code >}}
 
##### cluster_job:cortex_alertmanager_state_replication_failed_total:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job) (rate(cortex_alertmanager_state_replication_failed_total[5m]))
record: cluster_job:cortex_alertmanager_state_replication_failed_total:rate5m
{{< /code >}}
 
##### cluster_job:cortex_alertmanager_partial_state_merges_total:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job) (rate(cortex_alertmanager_partial_state_merges_total[5m]))
record: cluster_job:cortex_alertmanager_partial_state_merges_total:rate5m
{{< /code >}}
 
##### cluster_job:cortex_alertmanager_partial_state_merges_failed_total:rate5m

{{< code lang="yaml" >}}
expr: |
  sum by (cluster, job) (rate(cortex_alertmanager_partial_state_merges_failed_total[5m]))
record: cluster_job:cortex_alertmanager_partial_state_merges_failed_total:rate5m
{{< /code >}}
 
### mimir_ingester_rules

##### cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m

{{< code lang="yaml" >}}
expr: |
  sum by(cluster, namespace, pod) (rate(cortex_ingester_ingested_samples_total[1m]))
record: cluster_namespace_pod:cortex_ingester_ingested_samples_total:rate1m
{{< /code >}}
 
## Dashboards
Following dashboards are generated from mixins and hosted on github:


- [mimir-alertmanager-resources](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-alertmanager-resources.json)
- [mimir-alertmanager](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-alertmanager.json)
- [mimir-compactor-resources](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-compactor-resources.json)
- [mimir-compactor](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-compactor.json)
- [mimir-config](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-config.json)
- [mimir-object-store](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-object-store.json)
- [mimir-overrides](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-overrides.json)
- [mimir-overview-networking](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-overview-networking.json)
- [mimir-overview-resources](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-overview-resources.json)
- [mimir-overview](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-overview.json)
- [mimir-queries](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-queries.json)
- [mimir-reads-networking](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-reads-networking.json)
- [mimir-reads-resources](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-reads-resources.json)
- [mimir-reads](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-reads.json)
- [mimir-remote-ruler-reads-resources](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-remote-ruler-reads-resources.json)
- [mimir-remote-ruler-reads](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-remote-ruler-reads.json)
- [mimir-rollout-progress](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-rollout-progress.json)
- [mimir-ruler](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-ruler.json)
- [mimir-scaling](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-scaling.json)
- [mimir-slow-queries](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-slow-queries.json)
- [mimir-tenants](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-tenants.json)
- [mimir-top-tenants](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-top-tenants.json)
- [mimir-writes-networking](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-writes-networking.json)
- [mimir-writes-resources](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-writes-resources.json)
- [mimir-writes](https://github.com/observeproject/sites/blob/main/assets/mimir/dashboards/mimir-writes.json)
