(import 'mixin.libsonnet') + {
  _config+:: {
    product: 'Metric',
    
    graph_tooltip: 1,

    gateway_enabled: true,

    dashboard_datasource: 'cortex',
  },
}