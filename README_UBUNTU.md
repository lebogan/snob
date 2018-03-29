# Ubuntu Installation
## Preface
Okay, so I'm old. I started using Linux with Redhat 6 Hedwig (circa 1999). I have
since used only rpm-based os's. With so many currently enamoured with Ubuntu, I 
decided to give it a try. On a new vm (vagrant with VirtualBox provider)
running Ubuntu 14.04, I cloned and installed snob. Disaster! I kept getting an 
error about not finding libpcre.so.1. After some head scratching, this is what 
I came up with.

## Installation
First you need to install crystal and rebuild the executable. Then install and 
configure net-snmp.

### Prerequisites
- git
- realpath
- net-snmp  
There is a good write up on snmp by Justin Ellingwood on the DigitalOcean website 
[here](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-an-snmp-daemon-and-client-on-ubuntu-14-04).
```
$ sudo apt-get update
$ sudo apt-get install snmp snmp-mibs-downloader
```
- [crystal](https://crystal-lang.org/docs/installation/on_debian_and_ubuntu.html)
From the website use the Debian and Ubuntu manual install.
```
$ apt-key adv --keyserver keys.gnupg.net --recv-keys 09617FD37CC06B54
$ echo "deb https://dist.crystal-lang.org/apt crystal main" > /etc/apt/sources.list.d/crystal.list
$ apt-get update
$ sudo apt-get install crystal
```

### Build it (they will come)
```
$ git clone https://github.com/lebogan/snob.git
$ cd snob
$ shards install
$ crystal build --release --no-debug src/snob.cr
$ ./install.sh <answer yes>
```

### Snmp configuration
Apparantly, in Ubuntu-land, you need the snmp-mibs-downloader so you can refer to 
mibs by colorful names like ___system___ instead of 1.3.6.1.... There is an entry in 
`/etc/snmp/snmp.conf` that prevents that from happening. Comment out the line that
contains `mibs:`
```
# As the snmp packages come without MIB files due to license reasons, loading
# of MIBs is disabled by default. If you added the MIBs you can reenable
# loading them by commenting out the following line.
#mibs :
```
That's it. Have fun with this!
