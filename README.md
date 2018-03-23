# snob (Snmp Network Object Browser)
## Introduction
***This utility is experimental, it will change radically as I learn more of the
Crystal language, so use at your own risk!***

**snob** is an attempt to rewrite my Ruby app [YASB](https://github.com/lebogan/yasb.git)
in the Crystal programming language. The idea is to:

- have a somewhat easily distributable utility for
probing network devices using snmpV3
- share this utility with colleagues without them having to install some
development environment
- build fast performing apps
- learn Crystal while leveraging my Ruby experience
- have fun:)

This utility is written specifically for snmp version 3 because of
its security features. Backwards compatibility to version 2c is not included
at this time. Sorry:(.

The special *--list* switch is included to provide easily remembered names for
1.0.8802.1.1.2.1.4.1.1.9 or ipNetToPhysicalPhysAddress or other cryptic looking
oids.

The output is raw by default. In addition, a --dump option is included for dumping
the resulting output to a file, raw_dump.txt, for later perusal. A --format option
exists in an attempt to pretty-print the output for display on screen.

## Installation
You need ___git___ to proceed. Get git! The install script can also update snob by
pulling a fresh copy from github. Check out install.sh to see what the script
is doing. A utility, ***mibwalk***, is included in an attempt to make this more
stand-alone and reduce the reliance on net-snmp-utils. See ***TODO*** below.

```bash
$ git clone https://github.com/lebogan/snob.git
$ cd snob
$ ./install.sh
```
Required utilities for nms (network management station):  
-  git  

Optional utilities for nms and hosts:  
-  net-snmp  
-  net-snmp-utils  

Configure your hosts to respond to snmp requests. See documentation at: 
[net-snmp](http://net-snmp.sourceforge.net/docs/README.snmpv3.html)

## Usage
```bash
$ snob --help
Usage: snob [OPTIONS] [HOST]
Browse a host snmpv3 mib tree.

Prompts for HOST if not specified on the command-line. Also, prompts
for security credentials if HOST is not in the config file, ~/.snob/snobrc.yml.

    -l, --list                       List some pre-defined OIDs
    -m OID, --mib=OID                Display information for this oid
                                     (Default: system)
    -d, --dump                       Write output to file, raw only
    -f, --formatted                  Display formatted output
    -h, --help                       Show this help
    -v, --version                    Show version

$ snob --list
===================================================================
OIDS - Included pre-defined flag names
-------------------------------------------------------------------
flag name        |oid name
=================+=================================================
arp              |ipNetToPhysicalPhysAddress
-----------------+-------------------------------------------------
lldp             |1.0.8802.1.1.2.1.4.1.1.9
-----------------+-------------------------------------------------
sys              |system
-----------------+-------------------------------------------------
mem              |memory
-----------------+-------------------------------------------------
dsk              |dskTable
-----------------+-------------------------------------------------
ifdesc           |ifDescr
-----------------+-------------------------------------------------
distro           |ucdavis.7890.1.4
-----------------+-------------------------------------------------
temp             |lmTempSensorsDevice
-----------------+-------------------------------------------------
```
## Config file
A first run will create a default YAML config file named **~/.snob/snobrc.yml**
if it doesn't already exist. The directory's permissions are set to 0o700
(drwx------) for added security. The initial set of credentials is for a host named
__dummy__. Afterwards, if the host is not in the config file, you will be asked
to enter credentials manually with the option to save them.  
```
$ snob myserver
Config file doesn't exist. Create it? <yes>
myserver is not in config file. Configuring...
Enter security name: <myname>
Enter authentication phrase: <secret>
Enter privacy phrase: <realsecret>
Crypto algorithm [AES/DES]: <DES>
You entered: 
myserver:
  user: myname
  auth: secret
  priv: realsecret
  crypto: DES
Save this session? <yes>

```

The config file is YAML format and can be edited manually.
```text
# /home/vagrant/.snob/snobrc.yml
---
dummy:
  user: username
  auth: auth passphrase
  priv: priv passphrase
  crypto: AES/DES

myserver:
  user: myname
  auth: secret
  priv: realsecret
  crypto: DES
```

## TODO
- [ ] Include a mibwalk utility to ease reliance on external net-snmp-utils.      
- [ ] Bind the net-snmp c library to make this app even more portable.

## Development
Please, see the DISCLAIMER below.  
Check out the repo on GitHub at https://github.com/lebogan/snob.git  
Developed using Crystal 0.24.2 on Fedora 27 workstation running under Vagrant v2.0.2
with VirtualBox 5.2 provider.  
Tested on Fedora 26/27 and CentOS 7.  

## Contributing
Please, see the DISCLAIMER below.

1. Fork it ( https://github.com/[your-github-name]/snob/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors
- [lebogan](https://github.com/lebogan/snob.git) lebogan - creator, maintainer

## License
This utility is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

## Disclaimer
This utility was originally created for my personal use in my work as a network
specialist. It was developed on a Fedora Workstation using Crystal 0.24.2. This has
only been tested on Fedora 26/27 Workstation and CentOS 7 

I am not a professional software developer nor do I pretend to be. I am a retired IT 
network specialist and this is a hobby to keep me out of trouble. If you 
use this application and it doesn't work the way you would want, feel free to 
fork it and modify it to your liking. Fork on GitHub at https://github.com/lebogan/snob.git
