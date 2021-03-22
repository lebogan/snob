# #!/usr/bin/env bash
asciidoctor -a shards_version=$(shards version) -b manpage -D man docs/snob.1.adoc
asciidoctor -a shards_version=$(shards version) -b manpage -D man docs/snob.5.adoc
