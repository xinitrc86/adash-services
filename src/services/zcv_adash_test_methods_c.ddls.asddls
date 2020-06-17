@AbapCatalog.sqlViewName: 'ZVADASH_TESTS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Test methods of an entry'
@OData.publish: true
define view ZCV_ADASH_TEST_METHODS_C as select from ztbc_au_tests
     
{
    
   key cast( execution as abap.char( 32 ) ) as execution,
   key name,
   key type,
   key test_class as testClass,
   key test_method as testMethod,
   status,
   
   failure_header as failureHeader,
   failure_details as failureDetails
   
    
}  
 