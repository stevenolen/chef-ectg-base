#
# Cookbook Name:: ectg-base
# Recipe:: default
#
# Copyright (C) 2015 Steve Nolen
#
include_recipe 'curl'
include_recipe 'build-essential'
include_recipe 'iptables'
include_recipe 'git'
include_recipe 'nodejs::npm'
include_recipe 'openssh'
include_recipe 'openssl::upgrade'
include_recipe 'yum-epel'

# very basic postfix.
node.set['postfix']['main']['smtpd_use_tls'] = 'no'
node.set['postfix']['main']['smtp_use_tls'] = 'no'
include_recipe 'postfix'

# recommended vmware tools (disabling until tested alongside existing config.)
# package 'open-vm-tools'

selinux_state 'SELinux Permissive' do
  action :permissive
end

iptables_rule 'iptables_sshd' do
  # look for this rule in templates/default/iptables_sshd.
  source 'iptables_sshd.erb'
  name 'sshd'
  variables(
    port: 22 # abstract as variable if we ever need to set not as 22.
  )
  action :enable
end

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

# assumes sysadmin data bag exists. bad!
include_recipe 'users::sysadmins'

# chef-client config at the end
include_recipe 'chef-client::config'
include_recipe 'chef-client::init_service'
