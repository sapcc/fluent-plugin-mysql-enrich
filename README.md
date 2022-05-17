# fluent-plugin-mysql_enrich

A Fluent filter plugin to enrich a record with one or more tags.
The data for the enrichment can be selected from a MySQL/MariaDB and is cached.
The values in the column 'sql_key' of the database and the value in the record 'record_key' must correspond to each other.
These are used to store the rows in the cache and look them up for the enrichment.
The list of columns must correspond to the list of columns that the query returns. These specify which values are used to enrich the record.
Each column will be a new field in the record.

## Requirements

Fluentd >= v0.12

## Install

```shell
gem install fluent-plugin-mysql_enrich
```

## Configuration Example

```conf
<filter tag.dummy.*>
  type mysql_enrich
  host db.localhost
  port 3306
  database mydb
  username user
  password password123
  sql select * from foo;
  sql_key abc
  record_key remote_addr
  columns project_id, port_id
  refresh_interval 60
  read_timeout 60
</filter>
```

### sample

record before filter

```
{
  "remote_addr": 10.40.36.36
}
```

record after filter

```
{
    "remote_addr": 10.40.36.36,
    "project_id": myproject-id-1234,
    "port_id": 123123213123
}
```


## Parameters

* host (required)

  MariaDB host or ip

* port

  MariaDB port. Default is 3306 which is the MySQL default port.

* database (required)

  MariaDB database name

* username (required)

  MariaDB login user name

* password

  MariaDB login password. Default is empty string.

* sql (required)

  The sql statement that is executed to fill the cache.

* sql_key (required)

  The key field from the sql table that is used as the key in the cache. This must correspond to the record key. The record key is later used to do the lookups in the cache.

* record_key (required)

  The field from the record that is used for the lookups in the local cache. This must correspond to the sql_key.

* columns (required)

  The array of column names that are taken from the lookup result to enrich the record.

* refresh_interval

  The interval in seconds in which the local cache is refreshed. Default are 60 seconds.

* read_timeout

  Set read timeout in seconds for MySQL Connection, defaults to 60s

## Copyright

Copyright (c) 2020 SAP SE. See [LICENSE](LICENSE) for details.
