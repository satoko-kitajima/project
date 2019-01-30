#!/bin/sh

WORK_DIR=/opt/jobdirect/competitor_research/target/www.wantedly.com
CACHE_ROOT_DIR=${WORK_DIR}/cache
LOG_DIR=${WORK_DIR}/log

#export PATH=/opt/oracle/product/11.2.0/client_1/bin:${PATH}
#export ORACLE_HOME=/opt/oracle/product/11.2.0/client_1
export ORACLE_HOME=/opt/oracle/instantclient_11_2
export PATH=${ORACLE_HOME}:${PATH}
ORACLE_USER=kensaku
ORACLE_PASSWORD=kensaku
ORACLE_TNS_NAME=TRAVELR2

source /opt/jobdirect/competitor_research/target/common/scripts/common_function
source /opt/jobdirect/competitor_research/target/common/scripts/jd_logging

CONSOLE_LOG_FILE=${LOG_DIR}/crawler_console.log
JDLOGGING_LOG_FILE=${LOG_DIR}/start_JDCrawler.log
JDLOGGING_LOGGER_TAG="chuto13_"`basename $0`
jdlogging_init

jdlogging_log "start"

CRAWL_UNIT_ID=`get_new_crawl_unit_id`
jdlogging_log "CRAWL_UNIT_ID=${CRAWL_UNIT_ID}"
regist_new_crawl_unit_id ${CRAWL_UNIT_ID} 2 102 1

if [ -d ${CACHE_ROOT_DIR}/www.wantedly.com ]; then
    BACKUP_DATETIME=`date '+%Y%m%d-%H%M%S'`
    jdlogging_log "old cache was founnd, move to ${CACHE_ROOT_DIR}/${BACKUP_DATETIME}"
    mkdir -m 777 ${CACHE_ROOT_DIR}/${BACKUP_DATETIME}
    mv ${CACHE_ROOT_DIR}/www.wantedly.com ${CACHE_ROOT_DIR}/${BACKUP_DATETIME}
fi

pushd ${WORK_DIR}
/opt/openjdk/jdk-9.0.4/bin/java -jar selenium_crawler.jar properties:crawler.properties crawlUnitIDList:${CRAWL_UNIT_ID} > ${CONSOLE_LOG_FILE} 2>&1
${WORK_DIR}/crawl_and_regist_homepage_url.sh ${CRAWL_UNIT_ID}
popd
