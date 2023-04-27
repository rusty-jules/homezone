self: super:
{
  sqlite = super.sqlite.override {
    # https://github.com/canonical/microk8s/pull/2966
    NIX_CFLAGS_COMPILE = toString ([
      "-DSQLITE_ENABLE_DBSTAT_VTAB"
    ]);
  };
}
