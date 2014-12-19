#!/bin/sh
# Small script to setup the HBase tables used by OpenTSDB.

TABLES_PATH="/user/mapr"
TSDB_TABLE="$TABLES_PATH/tsdb"
UID_TABLE="$TABLES_PATH/tsdb-uid"
TREE_TABLE="$TABLES_PATH/tsdb-tree"
META_TABLE="$TABLES_PATH/tsdb-meta"

echo "Creating $TSDB_TABLE table..."
maprcli table create -path $TSDB_TABLE -defaultreadperm p -defaultwriteperm p -defaultappendperm p
maprcli table cf create -path $TSDB_TABLE -cfname t -maxversions 1 -inmemory false -compression lzf -ttl 0

echo "Creating $UID_TABLE table..."
maprcli table create -path $UID_TABLE -defaultreadperm p -defaultwriteperm p -defaultappendperm p
maprcli table cf create -path $UID_TABLE -cfname id -maxversions 1 -inmemory true -compression lzf -ttl 0
maprcli table cf create -path $UID_TABLE -cfname name -maxversions 1 -inmemory true -compression lzf -ttl 0

echo "Creating $TREE_TABLE table..."
maprcli table create -path $TREE_TABLE -defaultreadperm p -defaultwriteperm p -defaultappendperm p
maprcli table cf create -path $TREE_TABLE -cfname t -maxversions 1 -inmemory false -compression lzf -ttl 0

echo "Creating $META_TABLE table..."
maprcli table create -path $META_TABLE -defaultreadperm p -defaultwriteperm p -defaultappendperm p
maprcli table cf create -path $META_TABLE -cfname name -maxversions 1 -inmemory false -compression lzf -ttl 0

echo "Complete!"

