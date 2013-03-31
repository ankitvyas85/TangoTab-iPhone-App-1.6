


//******************** Production server location has to be Default *************

#define READING_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"
#define WRITING_DATE_FORMAT @"MMM dd yyyy"


#define QA_SERVER @"http://qa.tangotab.com/tangotabservices/services"
#define STAGE_SERVER @"http://stage.tangotab.com/tangotabservices/services"
#define PRODUCTION_SERVER @"http://services.tangotab.com/services"
#define DEVEL_SERVER @"http://192.168.131.106:8080/services"


#define ACTIVE_SERVER_URL STAGE_SERVER

#define _DEBUG 1

#ifdef _DEBUG
#define debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debug_NSLog(format, ...)
#endif