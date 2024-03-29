#CHANGELOG
## 1.2.0(2023-02-01)
- Update for Crystal 1.7.2
- Moved option parser to options.cr file.
- Use structs instead of named tuples for passing data to/from methods/classes.
- *(breaking-change)* Changed privacy protocol name from _crypto_ to _priv_ for consistant naming.
  Edit *snobrc.yml* to change. Or, run _sed -i.bak -e "/s/crypto/priv/g" ~/.snob/snobrc.yml_.
- Created a singleton registry for reading host credentials. Thanks @Blacksmoke16 for help.
- Added better error exception handling.
- Removed redundant helpers file.
- Added some color to messages.
- Remove object cross-compile for RaspberryPi3.
- General cleanup - make variable names more meaningful, use full module/class paths, etc.

## 1.1.2(2022-10-16)
- Update for Crystal 1.6.0

## 1.1.1(2022-09-27)
- Update for Crystal 1.5.1
- Update references to Centos to generic Redhat to reflect the demise of the
  community project. This mainly impacts Makefile and shell scripts.

## 1.1.0(2022-05-15)
- Update for Crystal 1.4.1
- Move main application into a separate _cli_ file for management purposes
- Update man pages

## 1.0.1(2021-09-01)
- Update for Crystal 1.1.1
- Update install script to include more distros
- Update man pages for Ascidoc format
- Move shell scripts to scripts/
- Add cross-compiled object files for RaspberryPi, Centos, Debian
- Fix tests

## 1.0.1-pre(2020-09-13)
- Update for Crystal 0.35.1 pending 1.0.0
- Add install for Raspberry Pi Model 4
- Integrate methods from myutils
- Add term-spinner and term-prompt shards for user interaction
- Allow application to invoke default editor on global config file
- Update docs

## 0.14.3 (2019-02-04)
- Update for Crystal 0.27.1

## 0.14.2 (2018-12-01)
- Update for Crystal 0.27.0
- Add myutils shard
- General syntax cleanup
- Update docs and tests

## 0.10.2 (2018-06-16)
- Update for Crystal 0.25.0
- Fixes an issue with secrets shard block arguments with loop statement:
[crystal-lang/crystal#6026](https://github.com/crystal-lang/crystal/pull/6026)

## 0.1.0 (2017-11-09)
- Initial release
