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
when 'debian'

  case
  when platform_version.to_f <= 5.0
    default['postgresql']['version'] = '8.3'
  when platform_version.to_f == 6.0
    default['postgresql']['version'] = '8.4'
  else
    default['postgresql']['version'] = '9.1'
  end

  default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql}

  set['postgresql']['data_dir'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  set['postgresql']['conf_dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"

when 'ubuntu'

  case
  when platform_version.to_f <= 9.04
    default['postgresql']['version'] = '8.3'
  when platform_version.to_f <= 11.04
    default['postgresql']['version'] = '8.4'
  else
    default['postgresql']['version'] = '9.1'
  end

  default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql}

  set['postgresql']['data_dir'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  set['postgresql']['conf_dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"

when 'fedora'

  if platform_version.to_f <= 12
    default['postgresql']['version'] = '8.3'
  else
    default['postgresql']['version'] = '8.4'
  end

  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}

  set['postgresql']['data_dir'] = '/var/lib/pgsql/data'
  set['postgresql']['conf_dir'] = '/var/lib/pgsql/data'

when 'amazon'

  default['postgresql']['version'] = '8.4'
  default['postgresql']['client']['packages'] = %w{postgresql-devel}
  default['postgresql']['server']['packages'] = %w{postgresql-server}

  set['postgresql']['data_dir'] = '/var/lib/pgsql/data'
  set['postgresql']['conf_dir'] = '/var/lib/pgsql/data'
when 'redhat','centos','scientific'

  default['postgresql']['version'] = '8.4'

  if node['platform_version'].to_f >= 6.0
    default['postgresql']['client']['packages'] = %w{postgresql-devel}
    default['postgresql']['server']['packages'] = %w{postgresql-server}
  else
    default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
    default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
  end

  set['postgresql']['data_dir'] = '/var/lib/pgsql/data'
  set['postgresql']['conf_dir'] = '/var/lib/pgsql/data'

when 'suse'

  case
  when platform_version.to_f <= 11.1
    default['postgresql']['version'] = "8.3"
  else
    default['postgresql']['version'] = "9.0"
  end

  set['postgresql']['dir'] = "/var/lib/pgsql/data"
  default['postgresql']['client']['packages'] = %w{postgresql-client libpq-dev}
  default['postgresql']['server']['packages'] = %w{postgresql-server}

  set['postgresql']['data_dir'] = '/var/lib/pgsql/data'
  set['postgresql']['conf_dir'] = '/var/lib/pgsql/data'

else
  default['postgresql']['version'] = '8.4'
  set['postgresql']['data_dir']         = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  set['postgresql']['conf_dir']         = "/etc/postgresql/#{node['postgresql']['version']}/main"
  
end

# Defaults for tunable settings

# file locations
default['postgresql']['hba_file']          = "#{node['postgresql']['conf_dir']}/pg_hba.conf"
default['postgresql']['ident_file']        = "#{node['postgresql']['conf_dir']}/pg_ident.conf"
default['postgresql']['external_pid_file']    = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
# connections
default['postgresql']['listen_addresses']     = 'localhost'
default['postgresql']['port']                 = 5432
default['postgresql']['max_connections']      = 100
default['postgresql']['unix_socket_directory']      = '/var/run/postgresql'

# security and authentication
default['postgresql']['ssl'] = 'off'
default['postgresql']['ssl_renegotiation_limit']  = '512MB'
default['postgresql']['ssl_ciphers'] = '!aNULL:!eNULL:!LOW:!EXPORT:!MD5:ALL'

# resource tuning
default['postgresql']['total_memory_percentage'] = 0.80
default['postgresql']['shared_memory_percentage']=0.25
default['postgresql']['effective_cache_size_percentage']=0.80

set['postgresql']['total_memory_mb']= PostgresqlCookbook::MemoryConversions.kibibytes_to_mebibytes(node['memory']['total'].to_i * node['postgresql']['total_memory_percentage']).to_i
set['postgresql']['shared_buffers']=(node['postgresql']['total_memory_mb'] * node['postgresql']['shared_memory_percentage']).to_i
set['postgresql']['effective_cache_size']=(node['postgresql']['total_memory_mb'] * node['postgresql']['effective_cache_size_percentage']).to_i

default['postgresql']['work_mem'] = '32MB'
default['postgresql']['maintenance_work_mem'] = '16MB'

# archiving
default['postgresql']['wal_level'] = 'minimal'
default['postgresql']['archive_mode'] = 'off'
default['postgresql']['archive_command'] = ""
# replication
default['postgresql']['max_wal_senders'] = 0
default['postgresql']['wal_keep_segments'] = 0
# standby
default['postgresql']['hot_standby'] = 'off'
# logs
default['postgresql']['log_destination']='csvlog'
default['postgresql']['logging_collector']='on'
default['postgresql']['log_directory']='/var/log/postgresql'
default['postgresql']['log_filename']='postgresql-%Y-%m-%d_%H%M%S'
default['postgresql']['log_file_mode']='0640'
default['postgresql']['log_rotation_age']='1d'
default['postgresql']['log_rotation_size']='100MB'
default['postgresql']['log_min_messages']='warning'
default['postgresql']['log_min_error_statement']='error'
default['postgresql']['log_min_duration_statement']=-1

#Authentication
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
