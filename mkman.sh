version=`shards version`
date=`date +"%Y-%m-%d"`
ronn --organization="${version}" --manual="User Commands" --date=$date man/snob.1.ronn
ronn --organization="${version}" --manual="File Formats" --date=$date man/snob.5.ronn

