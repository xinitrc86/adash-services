# ADASH Services
ADASH Services is the backend part of [ADASH Cli](https://github.com/xinitrc86/adash-cli). It can be used in conjunction with [ADASH Monitor](https://github.com/xinitrc86/adash-monitor) or any other interface adapted to consume its OData services. 

It consists of:
* An exposed rest API for usage by the cli or other tools. 
* Exposed OData services for usage by the monitor or other interfaces
* A report for job schedulling of tests runs. 

## Usage
Please refer to [ADASH Cli](https://github.com/xinitrc86/adash-cli).

## Installation
* Clone it or import the zip with [ABAPGit](https://github.com/larshp/abapGit).
  * This will activate ADASH services in /iwfnd/maint_services. Make sure they have a proper system alias after clonning.
  * Expose API in SICF with handler class zcl_adash_sicf_api_handler. 
    * If you wish to change the defult /sap/zadash path, you will need to change zcl_adash_sicf_api_handler with the new path too.
* Schedulle zpr_adash_setup_runner for monitoring.

## Compatibility 
Was developed on AS v753, should work on versions as low as v740sp08. Should require little effort to go as low as v740sp05. Lower than that is not possible, for now, as this was the first release with CDSs on. If you are up to creating the Gateway OData services for older versions, we can help.

## Dependencies
Make sure you clone the following repositories before this one.
[zassert](https://github.com/xinitrc86/zassert)
[ABAP Swagger](https://github.com/larshp/ABAP-Swagger)

## Monitoring
Schedule report zpr_adash_setup_runner for an automatic monitoring of your set up packages. We recommend two independent runs:
One without coverage that you can run every 15 minutes (unless somehow all of your tests takes longer than that).
One with coverage that you can run every half a day. Coverage Analyzer can take a long time depending on the amount of code it needs to analyze. Never go below 1 hour runs and keep an eye on your server loads from time to time.


## API
    https://<path_to_your_sys>:<your_sys>/<path to adash sicf node>    
    GET /{type}/{component}/add
    Adds a component to the automatic monitoring, executing a first test run and a first coverage run at the backround. 
    i.e: GET /devc/zpackage/add 
    

    GET /{type}/{component}/test 
    Run tests on given component and return is results. 
    i.e: GET /devc/zpackage/test    

    Response:    
    {
        "DATA": {
            "STATUS": "string",
            "SUMARIES": [
            {
                "MANDT": "string",
                "EXECUTION": "string",
                "TOTAL_TESTS": 0,
                "TOTAL_FAILED": 0,
                "TOTAL_SUCCESS": 0,
                "STATEMENTS_COUNT": 0,
                "STATEMENTS_COVERED": 0,
                "STATEMENTS_UNCOVERED": 0,
                "TIMESTAMP": 0,
                "NAME": "string",
                "TYPE": "string",
                "PACKAGE_OWN": "string",
                "PARENT_PACKAGE": "string"
            }
            ],
            "TESTS": [
            {
                "MANDT": "string",
                "EXECUTION": "string",
                "TEST_CLASS": "string",
                "TEST_METHOD": "string",
                "STATUS": "string",
                "FAILURE_HEADER": "string",
                "FAILURE_DETAILS": "string",
                "TIMESTAMP": 0,
                "NAME": "string",
                "TYPE": "string",
                "PACKAGE_OWN": "string",
                "PARENT_PACKAGE": "string"
            }
            ]
        }
    }


