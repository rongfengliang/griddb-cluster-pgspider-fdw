#!/bin/bash

chown gsadm.gridstore /var/lib/gridstore/data

IP=`grep $HOSTNAME /etc/hosts | awk ' { print $1 }'`

cat << EOF > /var/lib/gridstore/conf/gs_cluster.json
{
        "dataStore":{
                "partitionNum":128,
                "storeBlockSize":"64KB"
        },
        "cluster":{
                "clusterName":"defaultCluster",
                "replicationNum":2,
                "notificationInterval":"5s",
                "heartbeatInterval":"5s",
                "loadbalanceCheckInterval":"180s",
                "notificationMember": [
                        {
                                "cluster": {"address":"192.168.1.10", "port":10010},
                                "sync": {"address":"192.168.1.10", "port":10020},
                                "system": {"address":"192.168.1.10", "port":10080},
                                "transaction": {"address":"192.168.1.10", "port":10001},
                                "sql": {"address":"192.168.1.10", "port":20001}
                        },
                        {
                                "cluster": {"address":"192.168.1.11", "port":10010},
                                "sync": {"address":"192.168.1.11", "port":10020},
                                "system": {"address":"192.168.1.11", "port":10080},
                                "transaction": {"address":"192.168.1.11", "port":10001},
                                "sql": {"address":"192.168.1.11", "port":20001}
                        },
                        {
                                "cluster": {"address":"192.168.1.12", "port":10010},
                                "sync": {"address":"192.168.1.12", "port":10020},
                                "system": {"address":"192.168.1.12", "port":10040},
                                "transaction": {"address":"192.168.1.12", "port":10001},
                                "sql": {"address":"192.168.1.12", "port":20001}
                        }
                ]
        },
        "sync":{
                "timeoutInterval":"30s"
        }
}
EOF

cat << EOF > /var/lib/gridstore/conf/gs_node.json
{
    "dataStore":{
        "dbPath":"data",
        "backupPath":"backup",
        "syncTempPath":"sync",
        "storeMemoryLimit":"1024MB",
        "storeWarmStart":false,
        "storeCompressionMode":"NO_COMPRESSION",
        "concurrency":6,
        "logWriteMode":1,
        "persistencyMode":"NORMAL",
        "affinityGroupSize":4,
        "autoExpire":false
    },
    "checkpoint":{
        "checkpointInterval":"60s",
        "checkpointMemoryLimit":"1024MB",
        "useParallelMode":false
    },
    "cluster":{
        "servicePort":10010
    },
    "sync":{
        "servicePort":10020
    },
    "system":{
        "servicePort":10040,
        "eventLogPath":"log"
    },
    "transaction":{
        "servicePort":10001,
        "connectionLimit":5000
    },
    "trace":{
        "default":"LEVEL_ERROR",
        "dataStore":"LEVEL_ERROR",
        "collection":"LEVEL_ERROR",
        "timeSeries":"LEVEL_ERROR",
        "chunkManager":"LEVEL_ERROR",
        "objectManager":"LEVEL_ERROR",
        "checkpointFile":"LEVEL_ERROR",
        "checkpointService":"LEVEL_INFO",
        "logManager":"LEVEL_WARNING",
        "clusterService":"LEVEL_ERROR",
        "syncService":"LEVEL_ERROR",
        "systemService":"LEVEL_INFO",
        "transactionManager":"LEVEL_ERROR",
        "transactionService":"LEVEL_ERROR",
        "transactionTimeout":"LEVEL_WARNING",
        "triggerService":"LEVEL_ERROR",
        "sessionTimeout":"LEVEL_WARNING",
        "replicationTimeout":"LEVEL_WARNING",
        "recoveryManager":"LEVEL_INFO",
        "eventEngine":"LEVEL_WARNING",
        "clusterOperation":"LEVEL_INFO",
        "ioMonitor":"LEVEL_WARNING"
    }
}
EOF

gs_passwd admin -p admin
gs_startnode

sleep 5
while gs_stat -u admin/admin | grep RECOV > /dev/null; do
    echo Waiting for GridDB to be ready.
    sleep 5
done

gs_joincluster -n 1 -u admin/admin -n 3

tail -f /var/lib/gridstore/log/gridstore*.log