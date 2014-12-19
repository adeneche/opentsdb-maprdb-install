OpenTSDB/MapR-DB installation script
====================================

This project is a post install script for OpenTSDB to set it up to use MapR-DB instead of HBase.

##Step 0
Make sure you have either mapr-client or mapr-core installed

##Step 1
###Option 1 - Install with a package manager (RPM/DEB)
```
Download the appropriate installation package here: https://github.com/OpenTSDB/opentsdb/releases
*debian package*
	sudo dpkg -i DOWNLOADED_FILE_PATH
*rpm*
	sudo rpm -i DOWNLOADED_FILE_PATH
```

###Option 2 - Installation instructions on MapR 3.1.1/4.0.1
- build opentsdb from source
```
git clone https://github.com/OpenTSDB/opentsdb.git
cd opentsdb
./build.sh
```

- install opentsdb
```
cd build
sudo make install
sudo mkdir /usr/local/share/opentsdb/plugins
sudo ln -s /usr/local/share/opentsdb/etc/opentsdb /etc/opentsdb
sudo ln -s /usr/local/share/opentsdb/ /usr/share/opentsdb
```

##Step 2
*If you performed the install from a package manager (.rpm / .deb) then you can likely skip this step*
Verify that /var/log/opentsdb is owned by the user that will be running the server (e.g. opentsdb user) and has 0755 permissions

##Step 3
Open /etc/opentsdb/opentsdb.conf, and edit the following properties
You can change the path for the tables to anything you desire. Just ensure that the base folder e.g. /user/mapr exists in your MapR Distributed File System. This same path will be used in Step 6.
```
tsd.storage.enable_compaction = false *Ignore this setting for MapR-DB v4.x or above*
tsd.storage.hbase.data_table = /user/mapr/tsdb
tsd.storage.hbase.uid_table = /user/mapr/tsdb-uid
tsd.storage.hbase.meta_table = /user/mapr/tsdb-uid
tsd.storage.hbase.tree_table = /user/mapr/tsdb-uid
tsd.storage.hbase.zk_quorum = localhost:5181 *MapR-DB does not utilize this value, but it must be set to something*
```
##Step 4
```
git clone https://github.com/adeneche/opentsdb-maprdb-install.git
cd opentsdb-maprdb-install
```

##Step 5
- Edit install.sh and set __HADOOP_HOME__ and __OPENTSDB_HOME__ to the correct folders if they do not match your setup
- Run this install script to download and copy all the necessary JAR files to opentsdb lib folder
```
	run "sudo ./install.sh" 
```

##Step 6
- Edit the create_tables.sh and set your TABLES_PATH to the same path you used in Step 3
- Run the create tables script to create the OpenTSDB tables in MapR-DB
```
	run "sudo ./create_tables.sh"
```

##Step 7
You can now validate the installation
```
	tsdb import test_data --auto-metric
	tsdb scan --import 1y-ago sum mymetric.stock
```

