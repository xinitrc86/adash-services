@AbapCatalog.sqlViewName: 'ZVADASH_SETUP'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Adash setup'
@OData.publish: true
define view ZCV_ADASH_SETUP_C as select from ztbc_adash_setup 

{
    

    key mandt,
    key cast ( current_execution_guid as abap.char( 32 ) ) as currentExecutionGuid,
    key name as name,
    key type as type,
    keep_history as keepHistory,
    coverage_neutral as coverageNeutralLimit,
    max_duration_allowed as maxDuration,
    max_risk_level_allowed as maxRiskLevel,
    with_coverage as withCoverage
    
    
} 
 