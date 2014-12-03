#!/bin/bash
# opentsdb MapR-DB script
# this scripts makes the necessary arrangements to run opentsdb on MapR-DB
#
# opentsdb must be installed, either using .rpm or "make install" after building it

HADOOP_HOME=/opt/mapr/hadoop/hadoop-0.20.2
HBASE_HOME=/opt/mapr/hbase/hbase-0.94.21
OPENTSDB_HOME=/usr/local/share/opentsdb

#******************************************
# first check if required folders are available
echo "Check if required folders exist..."

test -d "$HADOOP_HOME" || {
  echo >&2 "'$HADOOP_HOME' doesn't exist, is mapr-client installed ?"
  exit 1
}
test -d "$HBASE_HOME" || {
  echo >&2 "'$HBASE_HOME' doesn't exist, is mapr-hbase installed ?"
  exit 1
}
test -d "$OPENTSDB_HOME" || {
  echo >&2 "'$OPENTSDB_HOME' doesn't exist, is openTSDB installed?"
  exit 1
}
#******************************************
# copy the necessary jars from HADOOP_HOME/lib/ to OPENTSDB_HOME/lib
#TODO create a symlink instead of copying the file
# Base of MapR installation

  for jar in "$HADOOP_HOME"/lib/*.jar; do
  if [ "`echo $jar | grep slf4j`" != "" ] || [ "`echo $jar | grep netty`" != "" ]; then
      continue
    fi
  echo "copying $jar..."
  cp "$jar" "$OPENTSDB_HOME/lib/"
  done

#******************************************
# download 'asynchbase-*-mapr.jar' into OPENTSDB_HOME
read -p "Press [Enter] to download asynchbase..."

if [[ `cat /opt/mapr/MapRBuildVersion` == 4* ]] ;
then
  echo "MapR 4.x installed. Downloading asynchbase 1.5.0"
  async_link=http://repository.mapr.com/nexus/content/groups/mapr-public/org/hbase/asynchbase/1.5.0-mapr-1408/asynchbase-1.5.0-mapr-1408.jar
else
  echo "MapR 3.x installed. Downloading asynchbase 1.4.1"
  async_link=http://repository.mapr.com/nexus/content/groups/mapr-public/org/hbase/asynchbase/1.4.1-mapr-1407/asynchbase-1.4.1-mapr-1407.jar
fi

async_file=`basename "$async_link"`

# but first check if it isn't already downloaded
test -f "$OPENTSDB_HOME/lib/$async_file" && {
  echo >&2 "'$async_file' found, no need to download it again"
  exit 0
}

wget $async_link -O "./$async_file-t"

#TODO we should probably checksum the file to make sure it downloaded correctly

# we need to replace the existing asynchbase jar by the one we will download from mapr
if ls $OPENTSDB_HOME/lib/asynchbase* &> /dev/null; then
  old_async=$(ls $OPENTSDB_HOME/lib/asynchbase*)
  mv $old_async "$old_async-old"
fi

mv "./$async_file-t" "$OPENTSDB_HOME/lib/$async_file"