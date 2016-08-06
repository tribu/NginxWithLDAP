#
# Cookbook Name:: nginxldap
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
include_recipe "chef_handler"
include_recipe "common::email_notification.rb"

include_recipe "nginxldap::install_nginx_with_ldap"

