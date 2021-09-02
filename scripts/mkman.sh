#!/usr/bin/env bash
touch docs/snob.1.adoc
touch docs/snob.5.adoc
asciidoctor -a shards_version="$(shards version)" -b manpage -D man docs/snob.1.adoc
asciidoctor -a shards_version="$(shards version)" -b manpage -D man docs/snob.5.adoc
