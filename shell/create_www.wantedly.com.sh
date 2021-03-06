#!/bin/sh
WORK_DIR=`dirname ${0}`

source ${WORK_DIR}/environment.sh
#source ${COMPETITOR_RESEARCH_HOME}/target/common/scripts/common_function

#CRAWL_UNIT_ID=`get_max_crawl_unit_id 2 101`
#echo ${CRAWL_UNIT_ID}
CRAWL_UNIT_ID=8226

sqlplus ${ORACLE_USER}/${ORACLE_PASSWORD}@${ORACLE_TNS_NAME} \
<< END_OF_SQL
    SET DEFINE OFF
    SET AUTOCOMMIT ON
    DROP TABLE T_WORK_WANTEDLY PURGE
    ;
    CREATE TABLE T_WORK_WANTEDLY AS
    SELECT
        P.ID             AS FID_TARGET,
        P.FID_DOMAIN     AS FID_DOMAIN,
        P.FID_MEDIA      AS FID_MEDIA,
        P.FID_SITE       AS FID_SITE,
        P.FID_CRAWL_UNIT AS FID_CRAWL_UNIT,
        'WANTEDLY' AS SITE_NAME,
        D1.DATA  AS WINDOW_NAME,
	D2.DATA  AS INDUSTRY,
	D3.DATA  AS JOB_CLASS,
	D4.DATA  AS STAFF_NUM,
	D5.DATA  AS COMPANY_VALUE_TITLE,
	D6.DATA  AS DETAIL_PAGE_URL
    FROM
        T_TARGET_ROOT_PAGE P
        LEFT JOIN T_TARGET_DATA D1  ON P.ID = D1.FID_TARGET  AND D1.LABEL  = 'window_name'
        LEFT JOIN T_TARGET_DATA D2  ON P.ID = D2.FID_TARGET  AND D2.LABEL  = 'industry'
        LEFT JOIN T_TARGET_DATA D3  ON P.ID = D3.FID_TARGET  AND D3.LABEL  = 'job_class'
        LEFT JOIN T_TARGET_DATA D4  ON P.ID = D4.FID_TARGET  AND D4.LABEL  = 'staff_num'
        LEFT JOIN T_TARGET_DATA D5  ON P.ID = D5.FID_TARGET  AND D5.LABEL  = 'company-value-title'
        LEFT JOIN T_TARGET_DATA D6  ON P.ID = D6.FID_TARGET  AND D6.LABEL = 'detail_page_url'
    WHERE
        P.FID_CRAWL_UNIT = ${CRAWL_UNIT_ID}
        AND
        P.STATUS = 4
        AND
        D1.DATA IS NOT NULL
        AND
        D5.DATA IS NOT NULL
    ORDER BY
        P.ID
    ;
    EXIT
    ;
END_OF_SQL
exit

