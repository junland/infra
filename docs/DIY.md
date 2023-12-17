# Do-It-Yourself

This document dumps most of the manual steps outside of this repository. This is either due because of a complex operation that would be hard to implment in code, `bootstrap` problem (Or something like that.), or just a low priority that I haven't implmented that step into this repository. 

## After imaging selfhosted server.

* Install `acme.sh` script, and edit `account.conf` in `~/.acme.sh`.
* Since my server has seperate SAS / RAID controller make sure to install `kmod-mpt3sas`.
* Set permissions for directories on ZFS so that Samba works with groups: `setfacl -R -m "g:sambashare:rwx" <DIRECTORY>`