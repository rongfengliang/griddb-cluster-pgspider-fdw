# griddb cluster learning (3 nodes)

> add pgspider:griddb for pg demo

## Usage

* start griddb cluster

```code
docker-compose up -d griddb-1 griddb-2 griddb-3
```

* start java application for insert demo datas

```code
docker-compose up -d griddb-java
```

* start pgspider with griddb fdw for connect

```code
docker-compose up -d  pgspider-griddb
```

* use griddb fdw do some connect

```code
CREATE EXTENSION griddb_fdw;
CREATE SERVER griddb_svr FOREIGN DATA WRAPPER griddb_fdw OPTIONS(notification_member 'griddb-1:10001,griddb-2:10001,griddb-3:10001',clustername 'defaultCluster');
CREATE USER MAPPING FOR public SERVER griddb_svr OPTIONS(username 'admin', password 'admin');
IMPORT FOREIGN SCHEMA griddb_schema FROM SERVER griddb_svr INTO public;
select * from col01;
```