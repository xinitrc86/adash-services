class ltc_results_db definition
for testing
duration short
risk level harmless
inheriting from zcl_assert.

  private section.
    constants default_guid type guid_32 value 'SELFTEST'.
    data cut type ref to zif_adash_results_db_layer.
    data results_container type ref to zif_adash_results_container.
    data selected_summaries type standard table of ztbc_au_results.
    data selected_test_results type standard table of ztbc_au_tests.
    methods:
      setup,
      teardown,
      it_saves for testing,
      it_updates_one for testing,
      it_saves_test_methods_result for testing,
      it_cleanse_entries_on_full_run for testing,
      it_keeps_entries_single_tst for testing,
      given_container_has_summary
        importing
          name        type c
          type        type c
          total_tests type i,
      when_persisting_container
        IMPORTING
          is_full_result_set TYPE abap_bool OPTIONAL,
      then_db_should_have_summary
        importing
          name        type c
          type        type c
          total_tests type any optional,
      then_record_count_for_guid_is
        importing
          expected_number_of_records type i
          count_test_results_too     type any optional,
      reset_instances
        IMPORTING
          is_full_run TYPE abap_bool default abap_true,
      then_should_find_history_for
        importing
          name        type c
          type        type c
          total_tests type i,
      given_a_setup_for_guid
        importing
          execution_guid type guid_32
          keep_history   type abap_bool,
      then_should_not_have_history
        importing
          name        type c
          type        type c
          total_tests type i,
      given_a_test_method_result
        importing
          name        type c
          type        type c
          test_class  type c
          test_method type c
          result      type i,
      then_db_should_have_test_methd
        importing
          name        type c
          type        type c
          test_class  type c
          test_method type c
          result      type i,
      then_has_test_methd_history
        importing
          name        type c
          type        type c
          test_class  type c
          test_method type c
          result      type i.


endclass.


class ltc_results_db implementation.

  method setup.

    reset_instances( ).

  endmethod.

  method teardown.

    "some tests commits twice, so we clear the db after
    delete from ztbc_au_results where execution = default_guid.
    delete from ztbc_au_tests where execution = default_guid.
    delete from ztbc_adash_setup where current_execution_guid = default_guid.


  endmethod.

  method it_saves.


    given_container_has_summary(
          name        = 'XXX_TEST'
          type        = 'CLAS'
          total_tests = 100 ).


    given_container_has_summary(
          name        = 'XXX_TEST2'
          type        = 'CLAS'
          total_tests = 100 ).


    when_persisting_container( ).

    then_db_should_have_summary(
          name = 'XXX_TEST'
          type = 'CLAS'
          total_tests = 100 ).


    then_db_should_have_summary(
          name = 'XXX_TEST2'
          type = 'CLAS'
          total_tests = 100 ).

    then_record_count_for_guid_is( 2 ).


  endmethod.

  method it_cleanse_entries_on_full_run.

    "between two runs, an object can be DELETED or RENAMED. It should not appear at last/current.
    "but this must be controlled through a "is_full_result_set, otherwise single tests would
    "always remove the last results of everyone else

    given_a_setup_for_guid(
        execution_guid = default_guid
        keep_history   = abap_true ).


    given_container_has_summary(
         name        = 'XXX_TEST7'
         type        = 'CLAS'
         total_tests = 100 ).

    given_a_test_method_result(
          name        = 'XXX_TEST7'
          type        = 'CLAS'
          test_class  = 'XXX_TEST7'
          test_method = 'IT_TESTS'
          result      = 1 ).

    when_persisting_container( ).

    reset_instances( ).

   "otherwise the 'new run' would have same timestamp
    wait up to 1 seconds.

    "object has been deleted
    given_container_has_summary(
         name        = 'XXX_TEST8'
         type        = 'CLAS'
         total_tests = 100 ).

    given_a_test_method_result(
          name        = 'XXX_TEST8'
          type        = 'CLAS'
          test_class  = 'XXX_TEST8'
          test_method = 'IT_TESTS'
          result      = 1 ).


    when_persisting_container( abap_true ).

    then_record_count_for_guid_is(
        expected_number_of_records = 1 "test 7 should not exist anymore
        count_test_results_too = abap_false ).

  endmethod.

  method it_keeps_entries_single_tst.

    "between two runs, an object can be DELETED or RENAMED. It should not appear at last/current.
    "but this must be controlled through a "is_full_result_set, otherwise single tests would
    "always remove the last results of everyone else

    given_a_setup_for_guid(
        execution_guid = default_guid
        keep_history   = abap_true ).


    given_container_has_summary(
         name        = 'XXX_TEST7'
         type        = 'CLAS'
         total_tests = 100 ).

    given_a_test_method_result(
          name        = 'XXX_TEST7'
          type        = 'CLAS'
          test_class  = 'XXX_TEST7'
          test_method = 'IT_TESTS'
          result      = 1 ).

    when_persisting_container( ).

    reset_instances(
        is_full_run = abap_false
    ).

   "otherwise the 'new run' would have same timestamp
   wait up to 1 seconds.

    "object has been deleted
    given_container_has_summary(
         name        = 'XXX_TEST8'
         type        = 'CLAS'
         total_tests = 100 ).

    given_a_test_method_result(
          name        = 'XXX_TEST8'
          type        = 'CLAS'
          test_class  = 'XXX_TEST8'
          test_method = 'IT_TESTS'
          result      = 1 ).


    when_persisting_container( ).

    then_record_count_for_guid_is(
        expected_number_of_records = 2 "test 7 should still exist
        count_test_results_too = abap_false ).

  endmethod.

  method it_updates_one.

    given_container_has_summary(
          name        = 'XXX_TEST3'
          type        = 'CLAS'
          total_tests = 100 ).


    when_persisting_container( ).

    then_db_should_have_summary(
          name = 'XXX_TEST3'
          type = 'CLAS'
          total_tests = 100 ).

    "to avoid sum
    reset_instances( ).

    given_container_has_summary(
          name        = 'XXX_TEST3'
          type        = 'CLAS'
          total_tests = 200 ).

    when_persisting_container( ).

    then_db_should_have_summary(
          name = 'XXX_TEST3'
          type = 'CLAS'
          total_tests = 200 ).


    then_record_count_for_guid_is( 1 ).

    then_should_not_have_history(
          name        = 'XXX_TEST3'
          type        = 'CLAS'
          total_tests = 100 ).


  endmethod.

  method it_saves_test_methods_result.

    given_a_setup_for_guid(
        execution_guid = default_guid
        keep_history   = abap_true ).

    given_container_has_summary(
          name        = 'XXX_TEST'
          type        = 'CLAS'
          total_tests = 100 ).

    given_a_test_method_result(
          name        = 'XXX_TEST'
          type        = 'CLAS'
          test_class  = 'XXX_TEST'
          test_method = 'IT_TESTS'
          result      = 1 ).

    when_persisting_container( ).

    then_db_should_have_test_methd(
          name        = 'XXX_TEST'
          type        = 'CLAS'
          test_class  = 'XXX_TEST'
          test_method = 'IT_TESTS'
          result      = 1 ).

    "for history checking
    when_persisting_container( ).

    then_record_count_for_guid_is(
        expected_number_of_records =  1
        count_test_results_too     =  abap_true
    ).



  endmethod.

  method given_container_has_summary.

    results_container->add_test_summary(
        value #(
            entry-name = name
            entry-type = type
            total_tests = total_tests
        )
    ).


  endmethod.

  method when_persisting_container.

    cut->persist(
        results_container = results_container
    ).

  endmethod.


  method then_db_should_have_summary.

    select single * from ztbc_au_results
    into @data(found_record)
    where name = @name
      and type = @type
      and total_tests = @total_tests
      and execution = @default_guid.

    assert_not_initial(
     act = found_record
     msg = 'Could not find the expected record on DB'
    ).

    assert_not_initial(
        act = found_record-timestamp
        msg = 'Should have stored operation timestamp!'
    ).

  endmethod.


  method then_record_count_for_guid_is.

    select * from ztbc_au_results
    into table @selected_summaries
    where execution = @default_guid.

    assert_equals(
         exp = expected_number_of_records
         act = lines( selected_summaries )
         msg = 'Different number of exepected records on DB for summary'
    ).


    if count_test_results_too eq abap_true.
      select * from ztbc_au_tests
      into table @selected_test_results
      where execution = @default_guid.

      assert_equals(
           exp = expected_number_of_records
           act = lines( selected_test_results )
           msg = 'Different number of exepected records on DB for test results'
      ).
    endif.

  endmethod.


  method reset_instances.

    cut = new zcl_adash_results_db_layer(  ).
    results_container = new zcl_adash_results_container(
        execution_guid = default_guid
        is_full_run = is_full_run ).
    clear selected_summaries.

  endmethod.


  method then_should_find_history_for.

    select single * from ztbc_au_results
    into @data(history_found)
    where name = @name
    and type = @type
    and total_tests = @total_tests
    and execution <> @default_guid.

    assert_not_initial(
        act = history_found
        msg = 'Could not find an history for the object'
    ).

    delete ztbc_au_results from history_found.

  endmethod.


  method given_a_setup_for_guid.

    data(adash_setup) = value ztbc_adash_setup(
        current_execution_guid = execution_guid
        keep_history    = keep_history
    ).

    modify ztbc_adash_setup from adash_setup.

  endmethod.


  method then_should_not_have_history.

    select single * from ztbc_au_results
    into @data(history_found)
    where name = @name
    and type = @type
    and total_tests = @total_tests
    and execution <> @default_guid.

    assert_initial(
        act = history_found
        msg = 'Should not have found history'
    ).

  endmethod.


  method given_a_test_method_result.

    results_container->add_test_method_result(
        value #(
            name = name
            type = type
            test_class = test_class
            test_method = test_method
            execution = default_guid
            status = result
        )

    ).

  endmethod.


  method then_db_should_have_test_methd.

    select single * from ztbc_au_tests
    into @data(record_found)
    where execution = @default_guid
      and name = @name
      and type = @type
      and test_class = @test_class
      and test_method = @test_method
      and status = @result.


    assert_not_initial(
        act = record_found
        msg = 'Could not find test method result'
    ).

  endmethod.


  method then_has_test_methd_history.

    select single * from ztbc_au_tests
    into @data(record_found2)
    where execution <> @default_guid
      and name = @name
      and type = @type
      and test_class = @test_class
      and test_method = @test_method
      and status = @result.


    assert_not_initial(
        act = record_found2
        msg = 'Could not find history for test method result'
    ).

  endmethod.

endclass.
