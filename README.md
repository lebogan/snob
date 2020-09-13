# snob (Snmp Network Object Browser)
## Introduction
***This utility is experimental, it will change radically as I learn more of the
Crystal language, so use at your own risk! There will be warts!***  

[Please, see the DISCLAIMER below](#disclaimer)

**snob** is a rewrite of my Ruby app [YASB](https://github.com/lebogan/yasb.git)
in the Crystal programming language. It's basically a wrapper around snmpwalk. The idea is to:

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
exists in an attempt to pretty-print the output for display on screen. The --only-values
flag allows output to be used raw by another application like RRDTool for graphing 
trends when you know which OID you want.

## Installation
This covers Ubuntu (14 - 20). See notes below for other distros.  

### Required
Required utilities for nms (network management station):  
- git  
- Install Crystal from the website, [crystal-lang](https://crystal-lang.org/docs/installation),
to build the utility from source.  
- snmp  
- snmp-mibs-downloader  

### Snmp configuration
There is an excellant write up on snmp by Justin Ellingwood and Vadym Kalsin on the DigitalOcean website 
[here](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-an-snmp-daemon-and-client-on-ubuntu-18-04
). They show how to configure a server and clients.  

You need the snmp-mibs-downloader so you can refer to 
mibs by colorful names like ___system___ instead of 1.3.6.1.... There is an entry in 
`/etc/snmp/snmp.conf` that prevents that from happening. Comment out the line that
contains `mibs:`
```
# As the snmp packages come without MIB files due to license reasons, loading
# of MIBs is disabled by default. If you added the MIBs you can reenable
# loading them by commenting out the following line.
mibs :
```

### Preferred Installation <a name="preferred-installation"></a>
A script, `install.sh`, is included to manage the installation process. It allows for
installation of a pre compiled binary or building from source. It also allows for
upgrading and uninstalling. See the additional notes for [Raspberry Pi 4](#rpibuild).

Check out install.sh to see what the script is doing.  

```bash
$ git clone https://github.com/lebogan/snob.git
$ cd snob
$ ./install.sh
```

### Manual Installation (if you gotta!)
___Note: not for Raspberry Pi!___  
A Makefile is included for compiling and installing the binary and man pages.
Crystal is required to be preinstalled. The binary is copied to `/usr/local/bin`.
The Makefile also provides for uninstalling and compliation cleanup. The compiled
binary is in `./bin`. Make also builds and installs man pages as necessary to
`/usr/local/share`.

```bash
$ git clone https://github.com/lebogan/snob.git
$ cd snob
$ shards install
$ make clean
$ make
$ sudo make install
```
#### RPM-based (RedHat) and other distributions
> The source will have to be recompiled with Crystal.  
> From the website, [crystal-lang](https://crystal-lang.org/install/)  
> See [Preferred Installation](#preferred-installation)

#### Debian 9
> Install Crystal [crystal-lang](https://crystal-lang.org/install/)  
> Install git and curl   
> Install libyaml-dev  
> Install apt-transport-https, dirmngr  
> For snmp, add to file: /etc/apt/sources.list
>```text
>deb http://ftp.br.debian.org/debian/ wheezy main contrib non-free
>deb-src http://ftp.br.debian.org/debian/ wheezy main contrib non-free
>```


## Usage
```bash
$ snob --help
Usage: snob [OPTIONS] [HOST]
Browse a host's snmpv3 mib tree.

Prompts for HOST if not specified on the command-line. Also, prompts
for security credentials if HOST is not in the config file, snobrc.yml.

    -l, --list                       List some pre-defined OIDs
    -m OID, --mib=OID                Display information for this oid
                                     (Default: system)
    -d, --dump                       Write output to file, raw only
    -e, --edit                       Edit global config file
    -f, --formatted                  Display as formatted table
    -o, --only-values                Display values only (not OID = value)
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
Config file doesn't exist. Create it(Y/n)? <Default: Yes>
'myserver' is not in config file. Configuring...
-----------------------------------------------
Enter security name: <myname>
Enter authentication phrase: <secret>
Enter privacy phrase: <realsecret>
Authentication: [MD5/SHA]: Default: SHA
Crypto algorithm [AES/DES]: Default: DES
-----------------------------------------------
Save these credentials(Y/n)? <Default: Yes>
```

The config file is YAML format and can be edited manually.
```text
# /home/<user>/.snob/snobrc.yml
---
dummy:
  user: username
  auth_pass: auth passphrase
  priv_pass: priv passphrase
  auth: MD5/SHA
  crypto: AES/DES


myserver:
  user: myname
  auth: secret
  priv: realsecret
  auth: MD5
  crypto: DES
```

## TODO
- [X] Add ability to do on-the-fly editing of config file using default system editor.
- [ ] Replace reliance on external snmpwalk to make this app even more portable.  
- [ ] Add build for Raspberry Pi Model 4

## Development
[Please, see the DISCLAIMER below](#disclaimer)  
Check out the repo on GitHub at https://github.com/lebogan/snob.git  


## Contributing
Please, see the DISCLAIMER below.

1. Fork it ( https://github.com/[your-github-name]/snob/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors
- [lebogan](https://github.com/lebogan/snob.git) - creator, maintainer

## License
This utility is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).

## Disclaimer <a name="disclaimer"></a>
This utility was originally created for my personal use in my work as a network
specialist. Developed using Crystal 0.35.1 on Ubuntu 18.04 virtual workstation running under Vagrant v2.2.5 with VirtualBox 6.0 provider.  


I am not a professional software developer nor do I pretend to be. I am a retired IT 
network specialist and this is a hobby to keep me out of trouble. If you 
use this application and it doesn't work the way you would want, feel free to 
fork it and modify it to your liking. Fork on GitHub at https://github.com/lebogan/snob.git

### Raspberry Pi (Raspberry Pi OS, Raspian 10)<a name="rpibuild"></a>
See [Preferred Installation](#preferred-installation). The binary has to be cross-compiled for the ARMv7 architecture.  

I have tested on a Raspberry Pi 4 Model B Rev 1.1 ARMv7 (4gb) running Raspian 10 and Crystal 0.33.1 and a Raspberry Pi 4 Model B Rev 1.4 ARMv7 (8gb) running Raspian 10, no llvm, no Crystal. Both work well.

> An object file, `snob.o` is included to aid in the cross-compiling effort.
> These files are required: `libpcre3-dev, libgc-dev, libyaml-dev, libreadline-dev, libevent-dev`.
> The install script will build a file, `libcrystal.a` and then build the binary
> from the object file.  
> For the snmp stuff, `snmp, snmpd, snmp-mibs-downloader, libsnmp-dev`, are needed.
> In addition, the `mibs:` line in `/etc/snmp/snmp.conf` needs to be commented out.