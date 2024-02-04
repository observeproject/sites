---
title: memcached
---

## Overview

Grafana dashboard for operating Memcached, in the form of a monitoring mixin.

{{< panel style="danger" >}}
Jsonnet source code is available at [github.com/grafana/jsonnet-libs](https://github.com/grafana/jsonnet-libs/tree/master/memcached-mixin)
{{< /panel >}}

## Alerts

{{< panel style="warning" >}}
Complete list of pregenerated alerts is available [here](https://github.com/observeproject/sites/blob/main/assets/memcached/alerts.yaml).
{{< /panel >}}

### memcached

##### MemcachedDown

{{< code lang="yaml" >}}
alert: MemcachedDown
annotations:
  description: Memcached instance {{ $labels.job }} / {{ $labels.instance }} is down for more than 15 minutes.
  summary: Memcached instance is down.
expr: |
  memcached_up == 0
for: 15m
labels:
  severity: critical
{{< /code >}}
 
##### MemcachedConnectionLimitApproaching

{{< code lang="yaml" >}}
alert: MemcachedConnectionLimitApproaching
annotations:
  description: Memcached instance {{ $labels.job }} / {{ $labels.instance }} connection usage is at {{ printf "%0.0f" $value }}% for at least 15 minutes.
  summary: Memcached max connection limit is approaching.
expr: |
  (memcached_current_connections / memcached_max_connections * 100) > 80
for: 15m
labels:
  severity: warning
{{< /code >}}
 
##### MemcachedConnectionLimitApproaching

{{< code lang="yaml" >}}
alert: MemcachedConnectionLimitApproaching
annotations:
  description: Memcached instance {{ $labels.job }} / {{ $labels.instance }} connection usage is at {{ printf "%0.0f" $value }}% for at least 15 minutes.
  summary: Memcached connections at critical level.
expr: |
  (memcached_current_connections / memcached_max_connections * 100) > 95
for: 15m
labels:
  severity: critical
{{< /code >}}
 
## Dashboards
Following dashboards are generated from mixins and hosted on github:


- [memcached-overview](https://github.com/observeproject/sites/blob/main/assets/memcached/dashboards/memcached-overview.json)
