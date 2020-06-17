@AbapCatalog.sqlViewName: 'ZVADASH_RESULTS'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Summary for packages'
@OData.publish: true
define view ZCV_ADASH_RESULTS_C as select from ztbc_au_results as _results
    inner join tadir as _validObject 
    on obj_name = _results.name
    and object = _results.type
    and delflag = ''

   
   association [0..1] to seoclasstx as _classDescription
   on   _classDescription.clsname = $projection.name
   and _classDescription.langu = 'E'

   association [0..1] to tdevct as _packageDescription
   on   _packageDescription.devclass = $projection.name
   and _packageDescription.spras = 'E'


   association [0..1] to trdirti as _programDescription
   on   _programDescription.name = $projection.name
   and _programDescription.sprsl = 'E'
   
   association [0..1] to tlibt as _fgDescription
   on _fgDescription.area = $projection.name
   and _fgDescription.spras = 'E'
   
    
{

   
   key cast( execution as abap.char( 32 ) ) as execution,
   key name,

   key case type
        when 'DEVC' then 1 // package
        else 2 //others
   end as type,

   key package_own,
   key parent_package,   
   
 
   type as typeRaw,  
   
   case
        when _classDescription.descript > '' then _classDescription.descript
        when _programDescription.text > '' then _programDescription.text 
        when _packageDescription.ctext > '' then _packageDescription.ctext
        when _fgDescription.areat > '' then _fgDescription.areat 
        else 'Unknown'
   end as description,
   
   
      
   total_tests as total,
   total_success as passed,
   total_failed as failed,
   statements_count as statements,
   statements_covered as covered,
   statements_uncovered as uncovered,
   
   case
        when total_failed > 0 then -1 //failed
        when total_success > 0 then 1 //passed 
        else 1 //neutral
   end
   as status,
   
   case total_tests
        when 0 then 0
        else cast (round(div( total_success * 100, total_tests ), 0) as abap.int1) 
   end as passingPercentage,
   
   case statements_count
        when 0 then 0
        else round(div( statements_covered * 100, statements_count ),0) 
   end as coveragePercentage
    
}  
 