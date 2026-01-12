# Note: This Dockerfile is based on apache/hive
# The following addons have been made:
#
# 3. AWS S3 jars added
# 4. Azure ADLS jars added

FROM apache/hive:4.1.0

MAINTAINER guido.schmutz@trivadis.com

ENV HIVE_HOME=/opt/hive
ENV HADOOP_VERSION=3.4.1
ENV AWS_SDK_V2_VERSION=2.25.63
ENV AZURE_STORAGE_VERSION=8.6.6
ENV AZURE_DL_SDK_VERSION=2.3.9
ENV M2=https://repo1.maven.org/maven2

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

# Install dependencies
RUN set -ex; \
    microdnf update -y; \
    microdnf -y install perl nc hostname; \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/hive && chmod 777 /tmp/hive

RUN wget --no-check-certificate https://jdbc.postgresql.org/download/postgresql-42.7.4.jar -O /opt/hive/lib/postgresql-42.7.4.jar
    
RUN curl -L $M2/software/amazon/awssdk/sdk-core/${AWS_SDK_V2_VERSION}/sdk-core-${AWS_SDK_V2_VERSION}.jar -o ${HIVE_HOME}/lib/sdk-core.jar && \
    curl -L $M2/software/amazon/awssdk/core/${AWS_SDK_V2_VERSION}/core-${AWS_SDK_V2_VERSION}.jar -o ${HIVE_HOME}/lib/core.jar && \
    curl -L $M2/software/amazon/awssdk/auth/${AWS_SDK_V2_VERSION}/auth-${AWS_SDK_V2_VERSION}.jar -o ${HIVE_HOME}/lib/auth.jar && \
    curl -L $M2/software/amazon/awssdk/regions/${AWS_SDK_V2_VERSION}/regions-${AWS_SDK_V2_VERSION}.jar -o ${HIVE_HOME}/lib/regions.jar && \
    curl -L $M2/software/amazon/awssdk/utils/${AWS_SDK_V2_VERSION}/utils-${AWS_SDK_V2_VERSION}.jar -o ${HIVE_HOME}/lib/utils.jar && \
    curl -L $M2/software/amazon/awssdk/s3/${AWS_SDK_V2_VERSION}/s3-${AWS_SDK_V2_VERSION}.jar -o ${HIVE_HOME}/lib/s3.jar && \
    curl -L $M2/software/amazon/awssdk/apache-client/${AWS_SDK_V2_VERSION}/apache-client-${AWS_SDK_V2_VERSION}.jar -o ${HIVE_HOME}/lib/apache-client.jar && \
    curl -L $M2/software/amazon/awssdk/awscore/${AWS_SDK_V2_VERSION}/awscore-${AWS_SDK_V2_VERSION}.jar -o ${HIVE_HOME}/lib/awscore.jar \
    curl -L $M2/org/apache/hadoop/hadoop-aws/${HADOOP_VERSION}/hadoop-aws-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-aws.jar && \
    curl -L $M2/com/azure/azure-storage/${AZURE_STORAGE_VERSION}/azure-storage-${AZURE_STORAGE_VERSION}.jar -o ${HIVE_HOME}/lib/azure-storage.jar && \
    curl -L $M2/com/azure/azure-data-lake-store-sdk/${AZURE_DL_SDK_VERSION}/azure-data-lake-store-sdk-${AZURE_DL_SDK_VERSION}.jar -o ${HIVE_HOME}/lib/azure-data-lake-store-sdk.jar && \
    curl -L $M2/org/apache/hadoop/hadoop-azure/${HADOOP_VERSION}/hadoop-azure-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-azure.jar && \
    curl -L $M2/org/apache/hadoop/hadoop-azure/${HADOOP_VERSION}/hadoop-azure-datalake-${HADOOP_VERSION}.jar -o ${HIVE_HOME}/lib/hadoop-azure-datalake.jar

ENV HADOOP_OPTIONAL_TOOLS=hadoop-azure,hadoop-azure-datalake
ENV HADOOP_CLASSPATH=/opt/hive/lib/*.jar:/opt/hadoop-$HADOOP_VERSION/share/hadoop/tools/lib/*.jar

USER hive

ENTRYPOINT ["entrypoint.sh"]

