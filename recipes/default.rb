#
# Cookbook Name:: mwser-base
# Recipe:: default
#
# Copyright (C) 2015 UC Regents
#

if node['platform_family'] == 'redhat' # redhat only items
  include_recipe 'yum-epel'
  selinux_state 'SELinux Permissive' do
    action :permissive
  end
  package 'bind-utils'
else
  package 'dnsutils'
end

include_recipe 'curl'
include_recipe 'build-essential'
include_recipe 'git'
include_recipe 'nodejs::npm'
include_recipe 'openssh'
include_recipe 'openssl::upgrade'
include_recipe 'vim'
package 'htop'

 case node['fqdn']
 when 'staging.ucnext.org', 'ucnext.org'
   # don't add sshd by default. allows world open
 else
   unless node.attribute?('cloud') && node['cloud']['provider'] == 'ec2'
    include_recipe 'mwser-iptables::sshd' # opens 22, although it is probably already open
   end
 end

# very basic postfix.
node.set['postfix']['main']['smtpd_use_tls'] = 'no'
node.set['postfix']['main']['smtp_use_tls'] = 'no'
include_recipe 'postfix'

# recommended vmware tools (disabling until tested alongside existing config.)
# package 'open-vm-tools'

node.set['ntp']['servers'] = if node.attribute?('cloud') && node['cloud']['provider'] == 'ec2'
                               [
                                 '0.amazon.pool.ntp.org',
                                 '1.amazon.pool.ntp.org',
                                 '2.amazon.pool.ntp.org',
                                 '3.amazon.pool.ntp.org'
                               ]
                             else
                               [
                                 'tick.ucla.edu',
                                 '0.pool.ntp.org',
                                 '1.pool.ntp.org',
                                 '2.pool.ntp.org',
                                 '3.pool.ntp.org'
                               ]
                             end
include_recipe 'ntp'
node.set['tz'] = 'America/Los_Angeles' # tz set to utc by default on ec2 instances
include_recipe 'timezone-ii'

# sudo
node.set['authorization']['sudo']['sudoers_defaults'] = [
  'env_reset',
  'env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE INPUTRC KDEDIR LS_COLORS"',
  'env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"',
  'env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"',
  'env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"',
  'env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"',
  'env_keep += "HOME"',
  'always_set_home',
  'secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"'
]
node.set['authorization']['sudo']['include_sudoers_d'] = true
node.set['authorization']['sudo']['groups'] = ['sudo']
include_recipe 'sudo'

sudo 'sysadmin' do
  group 'sysadmin'
  host 'ALL'
  nopasswd true
end

# assumes users data bag exists. bad!
users_manage 'sysadmin' do
  group_id 2300
  action [:remove, :create]
end

if node['fqdn'] == 'ucnext.org' || node['fqdn'] == 'staging.ucnext.org'
  # manage ucnext group
  users_manage 'ucnext' do
    action [:remove, :create]
  end

  # allow sudoer commands for ucnext
  sudo 'ucnext' do
    group 'ucnext'
    nopasswd true
    commands ['/usr/bin/chef-client', '/sbin/service ucnext-staging *', '/sbin/service ucnext-prod *']
  end
end

# chef-client config at the end
include_recipe 'chef-client::config'
include_recipe 'chef-client::init_service'
