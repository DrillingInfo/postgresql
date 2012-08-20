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

default[:postgresql][:listen_addresses] = "localhost"
default[:postgresql][:client_authentication] = {
  
  # Each authentication entry has a "key" field. This is not used by postgres, but
  # allows you to easily merge and override these attributes from your 
  # nodes, roles, etc.

  # It also has a "position" field, since sequence matters in pg_hba.conf, and
  # Ruby 1.8 hashes aren't ordered. Pro tip: if you want to insert a row, position can be a float!

  # WARNING: If you change the "admin" entry, you'll need to make sure that the 
  # database superuser can access the database using some other method.
  # Noninteractive access to all databases is required during automatic
  # maintenance (autovacuum, daily cronjob, replication, and similar tasks.)

  # Database administrative login by UNIX sockets
  :admin =>
    {
      :position => 1,
      :type     => 'local',
      :database => 'all',
      :user     => 'postgres',
      :method   => 'ident'
    },

  # Unix domain socket connections only
  :local_socket => 
    {
      :position => 2,
      :type     => 'local',
      :database => 'all',
      :user     => 'all',
      :method   => 'ident'
    },

  # IPv4 local connections
  :localhost_ipv4 =>
    {
      :position  => 3,
      :type     => 'host',
      :database => 'all',
      :user     => 'all',
      :cidr     => '127.0.0.1/32',
      :method   => 'md5'
    },

  # IPv6 local connections:
  :localhost_ipv6 =>
  {
    :position => 4,
    :type     => 'host',
    :database => 'all',
    :user     => 'all',
    :cidr     => '::1/128',
    :method   => 'md5'
  }
}