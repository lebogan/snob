#!/usr/bin/env bash
asciidoctor -r asciidoctor-epub3 -b epub3 -D docs README.adoc
asciidoctor -r asciidoctor-pdf -b pdf -D docs README.adoc
