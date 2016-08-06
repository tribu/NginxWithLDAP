#
# Cookbook Name:: nginxldap
# Recipe:: install_nginx_with_ldap
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

packages = ["pcre-devel",
            "pcre-static",
            "python-setuptools",
            "pcre-tools",
            "openldap-devel",
            "openssl-devel"
           ]

user 'nginx'

packages.each do |pkg|
  yum_package "#{pkg}"
end

remote_file "/tmp/nginx-auth-ldap-master.zip" do
  source "https://github.com/kvspb/nginx-auth-ldap/archive/master.zip"
    notifies :run, "bash[unzip_nginx-auth-ldap-master.zip]", :immediately
end

bash "unzip_nginx-auth-ldap-master.zip" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    unzip nginx-auth-ldap-master.zip
  EOH
  action :nothing
end

remote_file "/tmp/nginx-#{node[:nginx][:version]}.tar.gz" do
  source "http://nginx.org/download/nginx-#{node[:nginx][:version]}.tar.gz"
  notifies :run, "bash[untar_nginx]", :immediately
end

bash "untar_nginx" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    tar -zxf nginx-#{node[:nginx][:version]}.tar.gz
  EOH
  action :nothing
  notifies :run, "bash[install_nginx]", :immediately
end

bash "install_nginx" do
  user "root"
  cwd "/tmp/nginx-#{node[:nginx][:version]}"
  code <<-EOH
    ./configure --user=nginx --group=nginx --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-http_gzip_static_module --with-http_stub_status_module --with-http_ssl_module --with-pcre --with-file-aio --with-http_realip_module --add-module=/tmp/nginx-auth-ldap-master/ --with-ipv6 --with-debug
    make
    make install
  EOH
  action :nothing
end

template "/etc/init.d/nginx" do
  source "nginx.init.erb"
  mode '0700'
end
