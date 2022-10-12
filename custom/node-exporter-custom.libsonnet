(import 'mixin.libsonnet') + {
  _config+:: {
    nodeExporterSelector: 'job="node_exporter"',
  },
}