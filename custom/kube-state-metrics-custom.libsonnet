(import 'mixin.libsonnet') + {
  _config+:: {
    kubeStateMetricsSelector: 'job="kube-state-metrics"',
  },
}