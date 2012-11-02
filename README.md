Description
===========

Installs and configures PostgreSQL as a client or a server.

Requirements
============

## Platforms

* Debian, Ubuntu
* Red Hat/CentOS/Scientific (6.0+ required) - "EL6-family"
* Fedora
* SUSE

Tested on:

* Ubuntu 10.04, 11.10, 12.04
* Red Hat 6.1, Scientific 6.1, CentOS 6.3

## Cookboooks

Requires Opscode's `openssl` cookbook for secure password generation.

Requires a C compiler and development headers in order to build the
`pg` RubyGem to provide Ruby bindings in the `ruby` recipe.

Opscode's `build-essential` cookbook provides this functionality on
Debian, Ubuntu, and EL6-family.

While not required, Opscode's `database` cookbook contains resources
and providers that can interact with a PostgreSQL database. This
cookbook is a dependency of database.

Attributes
==========

The following attributes are set based on the platform, see the
`attributes/default.rb` file for default values.

* `node['postgresql']['version']` - version of postgresql to manage
* `node['postgresql']['data_dir']` - where postgresql data lives
* `node['postgresql']['conf_dir']` - where postgresql configuration lives

## SSL Configuration
* `node['postgresql']['ssl']` - whether to enable SSL. Defaults to off. For
  Ubuntu, you can turn it on, and postgres will use the "Snake Oil" certificate
  from the OpenSSL distro, so you can at least get up and running and replace
  the certificate in a later cookbook. On CentOS, you'll need to figure out how
  to get the certificate in place before running this recipe. The certificate,
  including the entire signing chain, must be placed in
  `"#{node['postgresql']['data_dir']/server.crt"` and the key must be in
  `"#{node['postgresql']['data_dir']/server.key"` and must not have a
  passphrase. Both files must be readable by the postgres user, and the key
  should be readable to _only_ the postgres user.
* `node['postgresql']['ssl_renegotiation_limit']` - the limit on the amount of
  data can be transferred in an SSL session before it is renegotiated and new
  keys are exchanged. Session renegotiation reduces the risk of cryptanalysis on
  the channel at the cost of performance. Defaults to 512MB. 
  **Note:** 
  Some SSL libraries shipped prior to November 2009 are insecure when using SSL
  renegotiation due to a vulnerability in the protocol. In response to the
  vulnerability, some vendors shipped SSL libraries incapable of renegotiation
  as a stop-gap measure. If using either a vulnerable or crippled library, SSL
  renegotiation should be disabled.
* `node['postgresql']['ssl_ciphers']` - An OpenSSL-style [cipher list](http://www.openssl.org/docs/apps/ciphers.html)
  of allowed SSL ciphers.  Defaults to '!aNULL:!eNULL:!LOW:!EXPORT:!MD5:ALL'

## Tunability

A number of attributes have been exposed for tuning the postgres installation.
The three most important are:

*  `node['postgresql']['total_memory_pct']` - The percentage of the node's total
   available memory that should be dedicated to postgresql. Defaults to 0.80
   (80%)
*  `node['postgresql']['shared_memory_percentage']` - The percentage of its
   memory that postgresql should dedicate to shared buffers. Defaults to 0.25
   (25%)
*  `node['postgresql']['effective_cache_size_percentage']` - The percentage of
   postgresql's total memory percentage that the query optimizer should assume
   is available for caching. Defaults to 0.80 (80%)

These three percentages will be used to calculate the values of several memory
related tunable parameters in the postgresql.conf file. These will be recorded
to the node as well (and can be hand-tuned to override the default
calculations):

* `node['postgresql']['total_memory_mb']` - The total memory, in mebibytes,
  allocated to postgresql.
* `node['postgresql']['shared_buffers']` - The value of the postgresql.conf
  `shared_buffers` parameter.
* `node['postgresql']['effective_cache_size']` - The value of the postgresql.conf
  `effective_cache_size` parameter.

## Logging

* `node['postgresql']['log_destination']` - The destination for log messages
  must be one of `stderr`, `csvlog`, or `syslog`. May also be a comma separated
  listing containing multiple of those (_e.g._ `stderr,csvlog`). Defaults to
  `csvlog`
* `node['postgresql']['logging_collector']` - This parameter captures plain and
  CSV-format log messages sent to stderr and redirects them into log files. This
  approach is often more useful than logging to syslog, since some types of
  messages might not appear in syslog output (a common example is dynamic-linker
  failure messages). Defaults to `on`. Required to be `on` if using the csvlog
  destination.
* `node['postgresql']['log_directory']` - The directory where log files should
  be saved. Defaults to `/var/log/postgresql`
* `node['postgresql']['log_filename']` - The pattern to use when generating log
  file names. Defaults to `postgresql-%Y-%m-%d_%H%M%S`
* `node['postgresql']['log_rotation_age']` - When logging_collector is enabled,
  this parameter determines the maximum lifetime of an individual log file.
  After this many minutes have elapsed, a new log file will be created. Set to
  zero to disable time-based creation of new log files. Defaults to `1d` (one
  day).
* `node['postgresql']['log_rotation_size']` - When logging_collector is enabled,
  this parameter determines the maximum size of an individual log file. When
  this limit is exceeded, a new log file will be created. Set to zero to disable
  size-based creation of new log files. Defaults to `100MB` (100 megabytes).
* `node['postgresql']['log_min_messages']` - Controls which message levels are
  written to the server log. Valid values are DEBUG5, DEBUG4, DEBUG3, DEBUG2,
  DEBUG1, INFO, NOTICE, WARNING, ERROR, LOG, FATAL, and PANIC. Each level
  includes all the levels that follow it. The later the level, the fewer
  messages are sent to the log. The default is WARNING.
* `node['postgresql']['log_min_error_statement']` - Controls which SQL
  statements that cause an error condition are recorded in the server log. The
  current SQL statement is included in the log entry for any message of the
  specified severity or higher. Valid values are DEBUG5, DEBUG4, DEBUG3, DEBUG2,
  DEBUG1, INFO, NOTICE, WARNING, ERROR, LOG, FATAL, and PANIC. The default is
  ERROR, which means statements causing errors, log messages, fatal errors, or
  panics will be logged. To effectively turn off logging of failing statements,
  set this parameter to PANIC.
* `node['postgresql']['log_min_duration_statement']` - Causes the duration of
  each completed statement to be logged if the statement ran for at least the
  specified number of milliseconds. Setting this to zero prints all statement
  durations. Minus-one (the default) disables logging statement durations. For
  example, if you set it to 250ms then all SQL statements that run 250ms or
  longer will be logged. Enabling this parameter can be helpful in tracking down
  unoptimized queries in your applications. Defaults to `-1`, disabling slow
  statement logging.

## Replication

### Replication Masters
* `node['postgresql']['max_wal_senders']` - Specifies the maximum number of
  concurrent connections from standby servers or streaming base backup clients
  (i.e., the maximum number of simultaneously running WAL sender processes). The
  default is zero, meaning replication is disabled. WAL sender processes count
  towards the total number of connections, so the parameter cannot be set higher
  than max_connections
* default['postgresql']['max_wal_senders']

### Replication Slaves

* `node['postgresql']['client']['packages']` - An array of package names
  that should be installed on "client" systems.
* `node['postgresql']['server']['packages']` - An array of package names
  that should be installed on "server" systems.


The following attribute is generated in `recipe[postgresql::server]`.

* `node['postgresql']['password']['postgres']` - randomly generated
  password by the `openssl` cookbook's library.

Recipes
=======

default
-------

Includes the client recipe.

client
------

Installs postgresql client packages and development headers during the
compile phase. Also installs the `pg` Ruby gem during the compile
phase so it can be made available for the `database` cookbook's
resources, providers and libraries.

ruby
----

**NOTE** This recipe may not currently work when installing Chef with
  the
  ["Omnibus" full stack installer](http://opscode.com/chef/install) on
  some platforms due to an incompatibility with OpenSSL. See
  [COOK-1406](http://tickets.opscode.com/browse/COOK-1406)

Install the `pg` gem under Chef's Ruby environment so it can be used
in other recipes.

server
------

Includes the `server_debian` or `server_redhat` recipe to get the
appropriate server packages installed and service managed. Also
manages the configuration for the server:

* generates a strong default password (via `openssl`) for `postgres`
* sets the password for postgres
* manages the `pg_hba.conf` file.

server\_debian
--------------

Installs the postgresql server packages, manages the postgresql
service and the postgresql.conf file.

server\_redhat
--------------

Manages the postgres user and group (with UID/GID 26, per RHEL package
conventions), installs the postgresql server packages, initializes the
database and manages the postgresql service, and manages the
postgresql.conf file.

Resources/Providers
===================

See the [database](http://community.opscode.com/cookbooks/database)
for resources and providers that can be used for managing PostgreSQL
users and databases.

Usage
=====

On systems that need to connect to a PostgreSQL database, add to a run
list `recipe[postgresql]` or `recipe[postgresql::client]`.

On systems that should be PostgreSQL servers, use
`recipe[postgresql::server]` on a run list. This recipe does set a
password and expect to use it. It performs a node.save when Chef is
not running in `solo` mode. If you're using `chef-solo`, you'll need
to set the attribute `node['postgresql']['password']['postgres']` in
your node's `json_attribs` file or in a role.

If you override the configuration defaults, you may need to change system
settings with sysctl (for example kernel.shmmax and fs.file-max) before
running `recipe[postgresql::server]`.

License and Author
==================

Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: Lamont Granquist (<lamont@opscode.com>)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
