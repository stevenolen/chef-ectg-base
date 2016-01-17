# ectg-base

A re-write of ucla/chef-ectg. 

## Supported Platforms

CentOS 6.x

## Usage

Most likely, you'll just want to scan through the 100 or so lines in the default recipe to see exactly what is being done. A few notes on quirky things are below though:

  * Applies `ectg-iptables::sshd` to all hosts except those noted (ucnext hosts). This is generally acceptable since we don't want to allow SSH outside the UCLA network unless needed.
  * SELinux is set to permissive mode. A historical necessity that I haven't had the opportunity to fix/test.
  * Manages users. See [ucla/chef-ectg-data_bags](https://github.com/ucla/chef-ectg-data_bags) for the user list
  * Manages `sysadmin` group and provides full sudo access to this group.
  * Lines 72-84 (or so) provide an example for managing an additional user group and specific sudo privileges.

## License and Authors

Author:: Steve Nolen (technolengy@gmail.com)
