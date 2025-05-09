# Note: This Dockerfile is based on https://hub.docker.com/r/bde2020/hadoop-base
# The following changes have been made:
#
# 1. Hadoop updated to 3.3.3
# 2. Hive updated to 3.1.5
# 3. AWS S3 jars added
# 4. Azure ADLS jars added

FROM apache/hive:3.1.3

MAINTAINER guido.schmutz@trivadis.com

ENV HIVE_HOME=/opt/hive
ENV HADOOP_VERSION=3.3.3
ENV AWS_VERSION=1.11.271
ENV AZURE_STORAGE_VERSION=7.0.0
ENV AZURE_DL_SDK_VERSION=2.3.6

#Custom configuration goes here
ADD conf/hive-site.xml $HIVE_HOME/conf
ADD conf/beeline-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-env.sh $HIVE_HOME/conf
ADD conf/hive-exec-log4j2.properties $HIVE_HOME/conf
ADD conf/hive-log4j2.properties $HIVE_HOME/conf
ADD conf/ivysettings.xml $HIVE_HOME/conf
ADD conf/llap-daemon-log4j2.properties $HIVE_HOME/conf

USER root
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN apt-get update && apt-get install -y curl 

RUN curl -L https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_VERSION}/aws-java-sdk-bundle-${AWS_VERSION}.jar -o ${HIVE_HOME}/lib/aws-java-sdk.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-aws.jar && \
    curl -L https://repo1.maven.org/maven2/com/azure/azure-storage/${AZURE_STORAGE_VERSION}/azure-storage-${AZURE_STORAGE_VERSION}.jar -o ${HIVE_HOME}/lib/azure-storage.jar && \
    curl -L https://repo1.maven.org/maven2/com/azure/azure-data-lake-store-sdk/${AZURE_DL_SDK_VERSION}/azure-data-lake-store-sdk-${AZURE_DL_SDK_VERSION}.jar -o ${HIVE_HOME}/lib/azure-data-lake-store-sdk.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/${HADOOP_VERSION}/hadoop-azure-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-azure.jar && \
    curl -L https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-azure/${HADOOP_VERSION}/hadoop-azure-datalake-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-azure-datalake.jar

ENV HADOOP_OPTIONAL_TOOLS=hadoop-azure,hadoop-azure-datalake
ENV HADOOP_CLASSPATH=/opt/hive/lib/*.jar:/opt/hadoop-$HADOOP_VERSION/share/hadoop/tools/lib/*.jar

USER hive

ENTRYPOINT ["entrypoint.sh"]

