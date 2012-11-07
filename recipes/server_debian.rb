#
# Cookbook Name:: postgresql
# Recipe:: server
#
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Lamont Granquist (<lamont@opscode.com>)#
# Copyright 2009-2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "postgresql::client"

node['postgresql']['server']['packages'].each do |pg_pack|
  package pg_pack do
    action :install
  end
end

service "postgresql" do
  case node['platform']
  when "ubuntu"
    case
    when node['platform_version'].to_f <= 10.04
      service_name "postgresql-#{node['postgresql']['version']}"
    else
      service_name "postgresql"
    end
  when "debian"
    case
    when node['platform_version'].to_f <= 5.0
      service_name "postgresql-#{node['postgresql']['version']}"
    else
      service_name "postgresql"
    end
  end
  supports :restart => true, :status => true, :reload => true
  action :nothing
end

directory node['postgresql']['unix_socket_directory'] do
  owner 'postgres'
  group 'postgres'
  mode '0755'
end

directory node['postgresql']['log_directory'] do
  owner 'postgres'
  group 'adm'
  mode '1750'
end

template "#{node['postgresql']['conf_dir']}/postgresql.conf" do
  source "postgresql.conf.erb"
  owner "postgres"
  group "postgres"
  mode 0600
  notifies :restart, resources(:service => "postgresql"), :immediately
end
