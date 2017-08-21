#!/bin/bash

printf "cat <<EOS\n`cat /opt/core-site.xml.tmpl`\nEOS\n" | sh > ${HADOOP_HOME}/etc/hadoop/core-site.xml
printf "cat <<EOS\n`cat /opt/hive-site.xml.tmpl`\nEOS\n" | sh > ${HIVE_HOME}/conf/hive-site.xml

${HIVE_HOME}/bin/schematool -dbType mysql -initSchema
${HIVE_HOME}/bin/hive --service metastore --hiveconf hive.aux.jars.path=${HADOOP_HOME}/share/hadoop/common/lib/*.jar
