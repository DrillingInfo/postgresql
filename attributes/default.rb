#
# Cookbook Name:: postgresql
# Attributes:: postgresql
#
# Copyright 2008-2009, Opscode, Inc.
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

case platform
when "debian"

  case
  when platform_version.to_f <= 5.0
    default[:postgresql][:version] = "8.3"
  when platform_version.to_f == 6.0
    default[:postgresql][:version] = "8.4"
  else
    default[:postgresql][:version] = "9.1"
  end

  set[:postgresql][:dir] = "/etc/postgresql/#{node[:postgresql][:version]}/main"

when "ubuntu"

  case
  when platform_version.to_f <= 9.04
    default[:postgresql][:version] = "8.3"
  when platform_version.to_f <= 11.04
    default[:postgresql][:version] = "8.4"
  else
    default[:postgresql][:version] = "9.1"
  end

  set[:postgresql][:dir] = "/etc/postgresql/#{node[:postgresql][:version]}/main"

when "fedora"

  if platform_version.to_f <= 12
    default[:postgresql][:version] = "8.3"
  else
    default[:postgresql][:version] = "8.4"
  end

  set[:postgresql][:dir] = "/var/lib/pgsql/data"

when "redhat","centos","scientific","amazon"

  default[:postgresql][:version] = "8.4"
  set[:postgresql][:dir] = "/var/lib/pgsql/data"

when "suse"

  if platform_version.to_f <= 11.1
    default[:postgresql][:version] = "8.3"
  else
    default[:postgresql][:version] = "8.4"
  end

  set[:postgresql][:dir] = "/var/lib/pgsql/data"

else
  default[:postgresql][:version] = "8.4"
  set[:postgresql][:dir]         = "/etc/postgresql/#{node[:postgresql][:version]}/main"
end


  <% if hash['type'] == 'local' -%>
<%= "#{hash['type']} #{hash['database']} #{hash['user']} #{hash['method']} #{hash['options']}" %>
  <% else -%>
<%= "#{hash['type']} #{hash['database']} #{hash['user']} #{hash['cidr']} #{hash['method']} #{hash['options']}" %>
  <% end -%>
<% end -%>



default[:postgresql][:listen_addresses] = "localhost"
default[:postgresql][:client_authentication] = [
  
  # If you change this first entry, you'll need to make sure that the 
  # database superuser can access the database using some other method.
  # Noninteractive access to all databases is required during automatic
  # maintenance (autovacuum, daily cronjob, replication, and similar tasks.)

  # Database administrative login by UNIX sockets
  {
    :type     => 'local',
    :database => 'all',
    :user     => 'postgres',
    :method   => 'ident'
  },

  # "local" is for Unix domain socket connections only
  {
    :type     => 'local',
    :database => 'all',
    :user     => 'all',
    :method   => 'ident'
  },

  # IPv4 local connections
  {
    :type     => 'host',
    :database => 'all',
    :user     => 'all',
    :cidr     => '127.0.0.1/32',
    :method   => 'md5'
  },

  # IPv6 local connections:
  {
    :type     => 'host',
    :database => 'all',
    :user     => 'all',
    :cidr     => '::1/128',
    :method   => 'md5'
  }
]