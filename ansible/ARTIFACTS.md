# Local Artifact Convention

All packages are resolved from local paths on each target host.
No internet download is performed by Ansible roles.

Base path:
- `local_artifact_root` (default: `/opt/artifacts`)

Expected layout:
- `/opt/artifacts/hadoop/*.tar.gz|*.tgz`
- `/opt/artifacts/hive/*.tar.gz|*.tgz`
- `/opt/artifacts/spark/*.tar.gz|*.tgz`
- `/opt/artifacts/kafka/*.tar.gz|*.tgz`
- `/opt/artifacts/impala/*.tar.gz|*.tgz`
- `/opt/artifacts/iceberg/*.jar`

Version match rule:
- Requested version can be full patch, for example `3.2.4`.
- Selector uses only `major.minor`, for example `3.2`.
- Matching artifacts are sorted by `sort -V`; highest patch is selected.

Example:
- `hadoop_version: "3.2.4"` or `hadoop_version: "3.2"`
- If local files include `hadoop-3.2.1.tgz`, `hadoop-3.2.4.tgz`, `hadoop-3.3.0.tgz`
- Selected file is `hadoop-3.2.4.tgz`
