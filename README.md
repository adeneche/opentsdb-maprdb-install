OpenTSDB/MapR-DB installation script
====================================

The goal of this script is to make it easier to run OpenTSDB on a MapR-DB cluster.
The only requirements is to have mapr-client (or mapr-core) installed and to install OpenTSDB
either by downloading the latest .rpm/.deb or by building from source then calling 'make install' from the build folder.

Installation instructions on MapR 3.1.1
- build opentsdb from source
	git clone https://github.com/OpenTSDB/opentsdb.git
	cd opentsdb
	./build.sh
- install opentsdb
	cd build
	sudo make install
	# the following shouldn't be required if you install opentsdb from .rpm/.deb
	sudo ln -s /usr/local/share/opentsdb/etc/opentsdb /etc/opentsdb
	sudo ln -s /usr/local/share/opentsdb/ /usr/share/opentsdb
	# we may want to create /var/log/opentsdb folder and give read/write access to the user who will launch tsdb "sudo chown mapr:mapr /var/log/opentsdb"
- edit /etc/opentsdb/opentsdb.conf
	# tsd.http.staticroot = /usr/local/share/opentsdb/static/
	# tsd.core.plugin_path = /usr/local/share/opentsdb/plugins
	tsd.storage.enable_compaction = false
	tsd.storage.hbase.data_table = /user/mapr/tsdb
	tsd.storage.hbase.uid_table = /user/mapr/tsdb-uid
	tsd.storage.hbase.zk_quorum = localhost:5181
- get this installation helpers
	cd <folder where you want to clone the installation helper>
	git clone https://github.com/adeneche/opentsdb-maprdb-install.git
	cd opentsdb-maprdb-install
- create the tables
 . MapR 3.1.1, there is a bug that prevent us from using a COMPRESSION setting
	env COMPRESSION=NONE HBASE_HOME=/opt/mapr/hbase/hbase-0.94.21 TSDB_TABLE=/user/mapr/tsdb UID_TABLE=/user/mapr/tsdb-uid TREE_TABLE=/user/mapr/tsdb-tree META_TABLE=/user/mapr/tsdb-meta ./create_table.sh
. MapR 4.0.1
 	cd /usr/local/share/opentsdb/tool
 	env COMPRESSION=none HBASE_HOME=/opt/mapr/hbase/hbase-0.94.21 ./create_table.sh
- run "sudo ./install.sh" to download and copy all the missing to opentsdb lib folder
- you can now test the installation:
	tsdb import test_data --auto-metric
	tsdb scan --import 1y-ago sum mymetric.stock
