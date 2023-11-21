---
title: pyroscope
---

## Overview



{{< panel style="danger" >}}
Jsonnet source code is available at [github.com/grafana/pyroscope.git](https://github.com/grafana/pyroscope.git/tree/master/operations/pyroscope/jsonnet/pyroscope-mixin/pyroscope-mixin)
{{< /panel >}}

## Recording rules

{{< panel style="warning" >}}
Complete list of pregenerated recording rules is available [here](https://github.com/observeproject/sites/blob/main/assets/pyroscope/rules.yaml).
{{< /panel >}}

### pyroscope_rules

##### job_cluster:pyroscope_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, job, cluster))
record: job_cluster:pyroscope_request_duration_seconds:99quantile
{{< /code >}}
 
##### job_cluster:pyroscope_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, job, cluster))
record: job_cluster:pyroscope_request_duration_seconds:50quantile
{{< /code >}}
 
##### job_cluster:pyroscope_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_sum[1m])) by (job, cluster) / sum(rate(pyroscope_request_duration_seconds_count[1m])) by (job, cluster)
record: job_cluster:pyroscope_request_duration_seconds:avg
{{< /code >}}
 
##### job_cluster:pyroscope_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, job, cluster)
record: job_cluster:pyroscope_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### job_cluster:pyroscope_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_sum[1m])) by (job, cluster)
record: job_cluster:pyroscope_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### job_cluster:pyroscope_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_count[1m])) by (job, cluster)
record: job_cluster:pyroscope_request_duration_seconds_count:sum_rate
{{< /code >}}
 
##### job_route_cluster:pyroscope_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, job, route, cluster))
record: job_route_cluster:pyroscope_request_duration_seconds:99quantile
{{< /code >}}
 
##### job_route_cluster:pyroscope_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, job, route, cluster))
record: job_route_cluster:pyroscope_request_duration_seconds:50quantile
{{< /code >}}
 
##### job_route_cluster:pyroscope_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_sum[1m])) by (job, route, cluster) / sum(rate(pyroscope_request_duration_seconds_count[1m])) by (job, route, cluster)
record: job_route_cluster:pyroscope_request_duration_seconds:avg
{{< /code >}}
 
##### job_route_cluster:pyroscope_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, job, route, cluster)
record: job_route_cluster:pyroscope_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### job_route_cluster:pyroscope_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_sum[1m])) by (job, route, cluster)
record: job_route_cluster:pyroscope_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### job_route_cluster:pyroscope_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_count[1m])) by (job, route, cluster)
record: job_route_cluster:pyroscope_request_duration_seconds_count:sum_rate
{{< /code >}}
 
##### namespace_job_route_cluster:pyroscope_request_duration_seconds:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, namespace, job, route, cluster))
record: namespace_job_route_cluster:pyroscope_request_duration_seconds:99quantile
{{< /code >}}
 
##### namespace_job_route_cluster:pyroscope_request_duration_seconds:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, namespace, job, route, cluster))
record: namespace_job_route_cluster:pyroscope_request_duration_seconds:50quantile
{{< /code >}}
 
##### namespace_job_route_cluster:pyroscope_request_duration_seconds:avg

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_sum[1m])) by (namespace, job, route, cluster) / sum(rate(pyroscope_request_duration_seconds_count[1m])) by (namespace, job, route, cluster)
record: namespace_job_route_cluster:pyroscope_request_duration_seconds:avg
{{< /code >}}
 
##### namespace_job_route_cluster:pyroscope_request_duration_seconds_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_bucket[1m])) by (le, namespace, job, route, cluster)
record: namespace_job_route_cluster:pyroscope_request_duration_seconds_bucket:sum_rate
{{< /code >}}
 
##### namespace_job_route_cluster:pyroscope_request_duration_seconds_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_sum[1m])) by (namespace, job, route, cluster)
record: namespace_job_route_cluster:pyroscope_request_duration_seconds_sum:sum_rate
{{< /code >}}
 
##### namespace_job_route_cluster:pyroscope_request_duration_seconds_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_request_duration_seconds_count[1m])) by (namespace, job, route, cluster)
record: namespace_job_route_cluster:pyroscope_request_duration_seconds_count:sum_rate
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_compressed_bytes:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(pyroscope_distributor_received_compressed_bytes_bucket[1m])) by (le, job, type, cluster))
record: job_type_cluster:pyroscope_distributor_received_compressed_bytes:99quantile
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_compressed_bytes:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(pyroscope_distributor_received_compressed_bytes_bucket[1m])) by (le, job, type, cluster))
record: job_type_cluster:pyroscope_distributor_received_compressed_bytes:50quantile
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_compressed_bytes:avg

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_distributor_received_compressed_bytes_sum[1m])) by (job, type, cluster) / sum(rate(pyroscope_distributor_received_compressed_bytes_count[1m])) by (job, type, cluster)
record: job_type_cluster:pyroscope_distributor_received_compressed_bytes:avg
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_compressed_bytes_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_distributor_received_compressed_bytes_bucket[1m])) by (le, job, type, cluster)
record: job_type_cluster:pyroscope_distributor_received_compressed_bytes_bucket:sum_rate
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_compressed_bytes_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_distributor_received_compressed_bytes_sum[1m])) by (job, type, cluster)
record: job_type_cluster:pyroscope_distributor_received_compressed_bytes_sum:sum_rate
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_compressed_bytes_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_distributor_received_compressed_bytes_count[1m])) by (job, type, cluster)
record: job_type_cluster:pyroscope_distributor_received_compressed_bytes_count:sum_rate
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_samples:99quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.99, sum(rate(pyroscope_distributor_received_samples_bucket[1m])) by (le, job, type, cluster))
record: job_type_cluster:pyroscope_distributor_received_samples:99quantile
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_samples:50quantile

{{< code lang="yaml" >}}
expr: histogram_quantile(0.50, sum(rate(pyroscope_distributor_received_samples_bucket[1m])) by (le, job, type, cluster))
record: job_type_cluster:pyroscope_distributor_received_samples:50quantile
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_samples:avg

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_distributor_received_samples_sum[1m])) by (job, type, cluster) / sum(rate(pyroscope_distributor_received_samples_count[1m])) by (job, type, cluster)
record: job_type_cluster:pyroscope_distributor_received_samples:avg
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_samples_bucket:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_distributor_received_samples_bucket[1m])) by (le, job, type, cluster)
record: job_type_cluster:pyroscope_distributor_received_samples_bucket:sum_rate
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_samples_sum:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_distributor_received_samples_sum[1m])) by (job, type, cluster)
record: job_type_cluster:pyroscope_distributor_received_samples_sum:sum_rate
{{< /code >}}
 
##### job_type_cluster:pyroscope_distributor_received_samples_count:sum_rate

{{< code lang="yaml" >}}
expr: sum(rate(pyroscope_distributor_received_samples_count[1m])) by (job, type, cluster)
record: job_type_cluster:pyroscope_distributor_received_samples_count:sum_rate
{{< /code >}}
 
## Dashboards
Following dashboards are generated from mixins and hosted on github:


- [pyroscope-reads](https://github.com/observeproject/sites/blob/main/assets/pyroscope/dashboards/pyroscope-reads.json)
- [pyroscope-writes](https://github.com/observeproject/sites/blob/main/assets/pyroscope/dashboards/pyroscope-writes.json)
