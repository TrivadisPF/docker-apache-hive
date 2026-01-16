# Note: This Dockerfile is based on apache/hive
# The following addons have been made:
#
# 3. AWS S3 jars added
# 4. Azure ADLS jars added

# Dockerfile adpated from https://github.com/arempter/hive-metastore-docker/blob/master/Dockerfile

FROM openjdk:8u342-jre

MAINTAINER guido.schmutz@trivadis.com

WORKDIR /opt


ENV HADOOP_VERSION=3.1.4
ENV METASTORE_VERSION=3.0.0
ENV HIVE_HOME=/opt/apache-hive-metastore-${METASTORE_VERSION}-bin
ENV AWS_SDK_VERSION=1.11.271
ENV AZURE_STORAGE_VERSION=8.6.6
ENV AZURE_DL_SDK_VERSION=2.3.9
ENV M2=https://repo1.maven.org/maven2

USER root
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install dependencies
RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        perl \
        netcat \
        hostname \
        curl \
        wget \
        ca-certificates; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/hive && chmod 777 /tmp/hive

RUN curl -L https://apache.org/dist/hive/hive-standalone-metastore-${METASTORE_VERSION}/hive-standalone-metastore-${METASTORE_VERSION}-bin.tar.gz | tar zxf - && \
    curl -L https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz | tar zxf - && \
    curl -L https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.19.tar.gz | tar zxf - && \
    cp mysql-connector-java-8.0.19/mysql-connector-java-8.0.19.jar ${HIVE_HOME}/lib/ && \
    rm -rf  mysql-connector-java-8.0.19

RUN groupadd -r hive --gid=1000 && \
    useradd -r -g hive --uid=1000 -d ${HIVE_HOME} hive && \
    chown hive:hive -R ${HIVE_HOME} && \
    chown hive:hive /entrypoint.sh && chmod +x /entrypoint.sh

RUN wget --no-check-certificate https://jdbc.postgresql.org/download/postgresql-42.7.4.jar -O ${HIVE_HOME}/lib/postgresql-42.7.4.jar
    
RUN curl -L $M2/com/amazonaws/aws-java-sdk-bundle/${AWS_SDK_VERSION}/aws-java-sdk-bundle-${AWS_SDK_VERSION}.jar -o ${HIVE_HOME}/lib/aws-java-sdk-bundle.jar && \
    curl -L $M2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-aws.jar && \
    curl -L $M2/com/azure/azure-storage/${AZURE_STORAGE_VERSION}/azure-storage-${AZURE_STORAGE_VERSION}.jar -o ${HIVE_HOME}/lib/azure-storage.jar && \
    curl -L $M2/com/azure/azure-data-lake-store-sdk/${AZURE_DL_SDK_VERSION}/azure-data-lake-store-sdk-${AZURE_DL_SDK_VERSION}.jar -o ${HIVE_HOME}/lib/azure-data-lake-store-sdk.jar && \
    curl -L $M2/org/apache/hadoop/hadoop-azure/${HADOOP_VERSION}/hadoop-azure-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-azure.jar && \
    curl -L $M2/org/apache/hadoop/hadoop-azure/${HADOOP_VERSION}/hadoop-azure-datalake-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-azure-datalake.jar

#Custom configuration goes here
ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

ENV HADOOP_OPTIONAL_TOOLS=hadoop-azure,hadoop-azure-datalake
ENV HADOOP_CLASSPATH=/opt/hive/lib/*.jar:/opt/hadoop-$HADOOP_VERSION/share/hadoop/tools/lib/*.jar
ENV HADOOP_HOME=/opt/hadoop-${HADOOP_VERSION}

USER hive
EXPOSE 9083

ENTRYPOINT ["entrypoint.sh"]

