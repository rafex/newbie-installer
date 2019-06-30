# Script Nginx compile

Here you will put the notes that are required to perfect the script

## Dependencies
1. the HTTP XSLT module requires the libxml2/libxslt
libraries. You can either do not enable the module or install the libraries.
2. the HTTP image filter module requires the GD library. You can either do not enable the module or install the libraries.
3. the GeoIP module requires the GeoIP library.
You can either do not enable the module or install the library.
4. the Google perftools module requires the Google perftools
library. You can either do not enable the module or install the library.
5. libatomic_ops library was not found.

```Shell
sudo apt install libxslt1-dev libxml2-dev libgd2-xpm libgd2-xpm-dev libgeoip-dev libgoogle-perftools-dev libatomic-ops-dev
```
