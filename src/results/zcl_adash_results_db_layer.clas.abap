class zcl_adash_results_db_layer definition
  public
  final
  create public .

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
    methods get_group_summary_records
      importing
                temp_summary   type zsbc_adash_result_summary_t
                group_guid     type guid_32
      returning value(results) type zsbc_adash_result_summary_t.
    methods should_keep_history_for_guid
      importing
        execution_guid type guid_32
      returning
        value(result)  type ztbc_adash_setup-keep_history.
    methods keep_current_sumary_as_history
      importing
        summaries      type zsbc_adash_result_summary_t
        execution_guid type guid_32.
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
    methods get_test_methods_on_group_guid
      importing
        test_methods_results type zsbc_adash_test_methods_t
        group_guid           type guid_32
      returning
        value(results)       type zsbc_adash_test_methods_t.
    methods keep_current_tests_as_history
      importing
        tests      type zsbc_adash_test_methods_t
        group_guid type guid_32.
    methods remove_deleted_entries.
endclass.



class zcl_adash_results_db_layer implementation.

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

    loop at temp_summary into data(group)
    group by group-execution.

      data(group_records) = get_group_summary_records(
            temp_summary = temp_summary
            group_guid   = group-execution ).

      if should_keep_history_for_guid( group-execution ).
        keep_current_sumary_as_history(
            execution_guid = group-execution
            summaries   = temp_summary ).
      endif.

      modify ztbc_au_results from table group_records.

    endloop.

  endmethod.


  method persist_test_method_results.

    "@TODO: How to handle delete/rename?

    data(test_methods_results) = apply_timestamp_to_test_methds( results_container ).
    check test_methods_results is not initial.
    data(new_time_stamp) = test_methods_results[ 1 ]-timestamp.


    loop at test_methods_results into data(group)
    group by group-package_own.

      data(group_records) = get_test_methods_on_group_guid(
            test_methods_results = test_methods_results
            group_guid           = group-execution ).

      if should_keep_history_for_guid( group-execution ).
        keep_current_tests_as_history(
            group_guid = group-execution
            tests = test_methods_results ).
      endif.

      modify ztbc_au_tests from table group_records.

    endloop.

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
  method get_group_summary_records.

    results = value zsbc_adash_result_summary_t( for row_in_group in temp_summary
        where ( execution = group_guid )
            ( row_in_group )
        ).

  endmethod.


  method get_test_methods_on_group_guid.

    results  = value zsbc_adash_test_methods_t(
    for row in test_methods_results
        where ( execution = group_guid )
        ( row )
    ).

  endmethod.


  method keep_current_sumary_as_history.

    "@sets a hash to the result, not
    "will have a different timestamp
    "and therefore, is now a history
    update ztbc_au_results
       set execution = @me->operation_guid
     where execution = @execution_guid.

  endmethod.


  method keep_current_tests_as_history.

    update ztbc_au_tests
    set execution = @me->operation_guid
    where execution = @group_guid.

  endmethod.



  method should_keep_history_for_guid.

    select single keep_history
    into      @result
    from ztbc_adash_setup
    where current_execution_guid = @execution_guid.

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
