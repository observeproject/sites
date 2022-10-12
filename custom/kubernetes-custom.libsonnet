(import 'mixin.libsonnet') + {
  // Config overrides used when building the compiled version of the mimir-mixin.
  // This includes all features, since the compiled version can't be customized.
  _config+:: {
    diskDeviceSelector: 'device=~"/dev/(%s)"' % std.join('|', self.diskDevices),
  },
}