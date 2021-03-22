#!/usr/bin/env bash

asciidoctor -r asciidoctor-epub3 -b epub3 -R docs docs/readme.adoc
asciidoctor -r asciidoctor-pdf -b pdf -R docs docs/readme.adoc
