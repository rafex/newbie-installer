# newbie-installer

The intention of these scripts is to facilitate the installation of tools that are commonly used. Do not try at any time to overcome a manager of more powerful packages or tools, it is simply to share a series of scripts that I have.

## Dependencies

### Debian / Ubuntu / Mint
```Shell
$ sudo apt-get update
$ sudo apt-get -y install build-essential git curl wget
```

### Alpine / 3.13.0
```Shell
$ sudo apk update
$ sudo apk add sudo git curl wget
```

### CentOS / RHEL 7/6/5
```Shell
$ sudo yum update
$ sudo yum groupinstall "Development Tools" git wget
```

### Fedora 28/29/30
```Shell
$ sudo dnf update
$ sudo dnf groupinstall "C Development Tools and Libraries" git wget
```
