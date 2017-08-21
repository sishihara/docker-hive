FROM openjdk:alpine
MAINTAINER Shoma Ishihara <sishihara@iij.ad.jp>

ARG http_proxy
ARG https_proxy
ARG hadoop_version=2.8.0
ARG hive_version=2.3.0
ARG awssdk_version=1.10.64
ARG jdbc_mysql_version=5.1.43

ENV HTTP_PROXY ${http_proxy}
ENV HTTPS_PROXY ${https_proxy}
ENV http_proxy ${http_proxy}
ENV https_proxy ${https_proxy}

ENV HADOOP_VERSION ${hadoop_version}
ENV HADOOP_HOME /opt/hadoop-${hadoop_version}

ENV HIVE_HOME /opt/apache-hive-${hive_version}-bin
ENV HIVE_VERSION ${hive_version}

RUN mkdir /work

ADD "http://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" /work/hadoop-${HADOOP_VERSION}.tar.gz
ADD "http://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" /work/apache-hive-${HIVE_VERSION}-bin.tar.gz

ADD http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-s3/${awssdk_version}/aws-java-sdk-s3-${awssdk_version}.jar /work/
ADD http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-kms/${awssdk_version}/aws-java-sdk-kms-${awssdk_version}.jar /work/
ADD http://central.maven.org/maven2/com/amazonaws/aws-java-sdk-core/${awssdk_version}/aws-java-sdk-core-${awssdk_version}.jar /work/
ADD http://central.maven.org/maven2/mysql/mysql-connector-java/${jdbc_mysql_version}/mysql-connector-java-${jdbc_mysql_version}.jar /work/

RUN mkdir /opt && cd /opt && \
      tar xzvf /work/hadoop-${HADOOP_VERSION}.tar.gz && \
      tar xzvf /work/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
      cp /work/aws-*-${awssdk_version}.jar /opt/hadoop-${HADOOP_VERSION}/share/hadoop/common/lib/ && \
      cp /work/mysql-connector*.jar /opt/apache-hive-${HIVE_VERSION}-bin/lib/ && \
      cd /opt/hadoop-${HADOOP_VERSION} && \
      cp share/hadoop/tools/lib/jackson*.jar share/hadoop/common/lib/ && \
      cp share/hadoop/tools/lib/joda*.jar share/hadoop/common/lib/ && \
      cp share/hadoop/tools/lib/hadoop-aws-*.jar share/hadoop/common/lib/ && \
      cp /work/aws-*-${awssdk_version}.jar share/hadoop/common/lib/ 

RUN apk add --no-cache bash

ADD core-site.xml.tmpl hive-site.xml.tmpl /opt/
ADD run.sh run-metastore.sh /

RUN chmod 755 /run.sh /run-metastore.sh && \
      rm -rf /work

EXPOSE 9083 10000

CMD ["/run.sh"]
