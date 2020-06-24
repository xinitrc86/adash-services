class zcl_adash_light_db_update definition
  public
  final
create private
  global friends zcl_adash_db_update_factory.

  public section.
    interfaces zif_adash_results_db_layer.
  protected section.
  private section.
    data operation_guid type sysuuid_c32.
    methods apply_timestamp_to_summaries
      importing
        results_container             type ref to zif_adash_results_container
      returning
        value(summary_with_timestamp) type zsbc_adash_result_summary_t.
    methods create_new_operation_guid.
    methods persist_summary_results
      importing
        results_container type ref to zif_adash_results_container.
    methods persist_test_method_results
      importing
        results_container type ref to zif_adash_results_container.
    methods apply_timestamp_to_test_methds
      importing
        results_container type ref to zif_adash_results_container
      returning
        value(results)    type zsbc_adash_test_methods_t.
    methods remove_deleted_entries.

endclass.



class zcl_adash_light_db_update implementation.

  method zif_adash_results_db_layer~persist.

    create_new_operation_guid( ).
    persist_summary_results( results_container ).
    persist_test_method_results( results_container ).
    remove_deleted_entries( ).

  endmethod.


  method create_new_operation_guid.

    try.
        me->operation_guid = cl_system_uuid=>create_uuid_c32_static( ).
      catch cx_uuid_error.
        "handle exception?
    endtry.

  endmethod.

  method persist_summary_results.

    "@TODO: How to handle objects that are deleted/renamed?
    data(temp_summary) = apply_timestamp_to_summaries( results_container ).
    check temp_summary is not initial.
    data(new_time_stamp) = temp_summary[ 1 ]-timestamp.
    data(guid) = temp_summary[ 1 ]-execution.

    modify ztbc_au_results from table temp_summary.

  endmethod.


  method persist_test_method_results.

    "@TODO: How to handle delete/rename?

    data(test_methods_results) = apply_timestamp_to_test_methds( results_container ).
    check test_methods_results is not initial.
    data(new_time_stamp) = test_methods_results[ 1 ]-timestamp.
    data(guid) = test_methods_results[ 1 ]-execution.

    modify ztbc_au_tests from table test_methods_results.

  endmethod.

  method apply_timestamp_to_summaries.

    summary_with_timestamp  = results_container->get_adash_results_summary(  ).
    get time stamp field data(time_stamp).
    modify summary_with_timestamp from value #( timestamp = time_stamp ) transporting timestamp
    where timestamp = ''.
    "@TODO results_container->set_adash_results_summary( summary_with_timestamp )

  endmethod.

  method apply_timestamp_to_test_methds.

    results  = results_container->get_adash_test_method_results( ).
    get time stamp field data(time_stamp).
    modify results from value #( timestamp = time_stamp ) transporting timestamp
    where timestamp = ''.
    "@TODO results_container->set_adash_test_method_results( results )

  endmethod.


  method remove_deleted_entries.

    select execution, name,type,package_own,parent_package from ztbc_au_results as result
    inner join tadir as _deleted
    on _deleted~object = result~type
    and _deleted~obj_name = result~name
    and _deleted~delflag = @abap_true
    into @data(deleted)
    where execution = 'LAST'.


      delete ztbc_au_results from @( corresponding #( deleted ) ).
      delete from ztbc_au_tests
      where execution = deleted-execution
        and name = deleted-name
        and type = deleted-type .


    endselect.

  endmethod.

endclass.
