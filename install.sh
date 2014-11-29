#!/bin/sh
# opentsdb MapR-DB script
# this scripts makes the necessary arrangements to run opentsdb on MapR-DB
#
# opentsdb must be installed, either using .rpm or "make install" after building it

HADOOP_HOME=/opt/mapr/hadoop/hadoop-0.20.2
OPENTSDB_HOME=/usr/local/share/opentsdb

#******************************************
# first check if required folders are available
test -d "$HADOOP_HOME" || {
  echo >&2 "'$HADOOP_HOME' doesn't exist, is mapr-client installed ?"
  exit 1
}
test -d "$OPENTSDB_HOME" || {
  echo >&2 "'$OPENTSDB_HOME' doesn't exist, is openTSDB installed?"
  exit 1
}

#******************************************
# copy the necessary jars from HADOOP_HOME/lib/ to OPENTSDB_HOME/lib
#TODO create a symlink instead of copying the file

copy_if_exists() {
	test -f "$1" || {
  		echo >&2 "'$1' doesn't exist !!!"
  		exit 1
	}

	echo "copying $1..."
	cp "$HADOOP_HOME/lib/$1" "$OPENTSDB_HOME/lib/"
}

copy_if_exists "commons-logging-api-1.0.4.jar"
copy_if_exists "hadoop-0.20.2-auth.jar"
copy_if_exists "hadoop-0.20.2-dev-core.jar"
copy_if_exists "protobuf-java-2.4.1.jar"
copy_if_exists "libprotodefs-1.0.3-mapr-3.1.1.jar"
copy_if_exists "maprfs-1.0.3-mapr-3.1.1.jar"
copy_if_exists "json-20080701.jar"

#******************************************
# download 'asynchbase-1.4.1-mapr.jar' into OPENTSDB_HOME

# but first check if it isn't already downloaded
test -f "$OPENTSDB_HOME/lib/asynchbase-1.4.1-mapr.jar" && {
  echo >&2 "'asynchbase-1.4.1-mapr.jar' found, no need to download it again"
  exit 0
}

url=http://repository.mapr.com/nexus/service/local/repositories/releases/content/org/hbase/asynchbase/1.4.1-mapr/asynchbase-1.4.1-mapr.jar
wget $url -O "./asynchbase-1.4.1-mapr.jar-t"

#TODO we should probably checksum the file to make sure it downloaded correctly

# we need to replace the existing asynchbase jar by the one we will download from mapr
if ls $OPENTSDB_HOME/lib/asynchbase* &> /dev/null; then
  old_async=$(ls $OPENTSDB_HOME/lib/asynchbase*)
  mv $old_async "$old_async-old"
fi

mv "./asynchbase-1.4.1-mapr.jar-t" "$OPENTSDB_HOME/lib/asynchbase-1.4.1-mapr.jar"
