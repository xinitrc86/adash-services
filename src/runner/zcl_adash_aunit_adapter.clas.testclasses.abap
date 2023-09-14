class ltc_aunit_result_adapter definition
for testing
duration short
risk level harmless
inheriting from zcl_assert.


  private section.
    data:
      o_cut                 type ref to zcl_adash_aunit_adapter,
      resultmock            type ref to cl_saunit_internal_result,
      s_task_data           type if_saunit_internal_result_type=>ty_s_task,
      s_summary             type zsbc_test_summary,
      t_results             type zsbc_adash_result_summary_t,
      t_test_method_results type zsbc_adash_test_methods_t.
    methods:
      it_summarizes_results for testing,
      it_returns_coverage for testing,
      it_collects_test_methods for testing,
      given_a_test_method_entry
        importing
          iv_program_name type c
          iv_test_class   type c
          iv_test_method  type c,
      given_an_alert_for
        importing
          iv_program_index type i
          iv_class_index   type i
          iv_method_index  type i
          iv_alert_type    type c,
      when_asking_for_results,
      then_should_have_result
        importing
          i_type    type c
          i_name    type c
          i_package type c
          i_parent  type c
          i_total   type i
          i_failed  type i
          i_passed  type i,
      then_test_method_result_is
        importing
          expected_name        type c
          expected_type        type c
          expected_package     type c
          expected_test_class  type c
          expected_test_method type c
          expected_status      type i.

endclass.


class ltc_aunit_result_adapter implementation.


  method it_summarizes_results.


    given_a_test_method_entry(
          iv_program_name = 'ZCL_ADASH_AUNIT_ADAPTER=======CP'
          iv_test_class   = 'LCL_TEST_OF_PROGRAM'
          iv_test_method  = 'IT_TESTS_SOMETHING' ).

    given_a_test_method_entry(
          iv_program_name = 'ZCL_ADASH_AUNIT_ADAPTER=======CP'
          iv_test_class   = 'LCL_TEST_OF_PROGRAM'
          iv_test_method  = 'IT_TESTS_SOMETHING2' ).

    "Another test class within the same program
    given_a_test_method_entry(
          iv_program_name = 'ZCL_ADASH_AUNIT_ADAPTER=======CP'
          iv_test_class   = 'LCL_OTHER_TEST'
          iv_test_method  = 'IT_TESTS_SOMETHING' ).


    given_an_alert_for(
          iv_program_index = 1
          iv_class_index   = 2
          iv_method_index  = 1
          iv_alert_type    = 'F' ).


    when_asking_for_results( ).

    then_should_have_result(
         i_type    = 'CLAS'
         i_name    = 'ZCL_ADASH_AUNIT_ADAPTER'
         i_package = 'ZBC_ADASH_RUNNER'
         i_parent  = 'ZBC_ADASH'
         i_total   = 3
         i_failed  = 1
         i_passed  = 2 ).

  endmethod.

  method it_returns_coverage.


  endmethod.

  method it_collects_test_methods.

    given_a_test_method_entry(
        iv_program_name = 'ZCL_ADASH_AUNIT_ADAPTER=======CP'
        iv_test_class   = 'LCL_TEST_OF_PROGRAM'
        iv_test_method  = 'IT_TESTS_SOMETHING' ).

    given_an_alert_for(
          iv_program_index = 1
          iv_class_index   = 1
          iv_method_index  = 1
          iv_alert_type    = 'F' ).

    when_asking_for_results( ).


    then_test_method_result_is(
          expected_name        = 'ZCL_ADASH_AUNIT_ADAPTER'
          expected_type        = 'CLAS'
          expected_package     = 'ZBC_ADASH_RUNNER'
          expected_test_class  = 'LCL_TEST_OF_PROGRAM'
          expected_test_method = 'IT_TESTS_SOMETHING'
          expected_status      = -1 ). "failed



  endmethod.


  method given_a_test_method_entry.

    "@TODO: refactor into human language
    data(ls_program_entry) = value if_saunit_internal_result_type=>ty_s_program( ).

    read table s_task_data-programs
    assigning field-symbol(<ls_program_entry>)
    with key info-name = iv_program_name.

    if sy-subrc <> 0.
      ls_program_entry = value #(
          info = value #( name = iv_program_name )
          classes = value #(
              (
              info = value #( name = iv_test_class )
              methods = value #(
                  ( info = value #( name = iv_test_method ) )
              )

                  )
          )
      ).

      append ls_program_entry to s_task_data-programs.

    else.
      read table <ls_program_entry>-classes
      with key info-name = iv_test_class
      assigning field-symbol(<ls_test_class>).

      if sy-subrc <>  0.
        append value #(
         info = value #( name = iv_test_class )
         methods = value #( ( info = value #( name = iv_test_method ) ) )
        ) to <ls_program_entry>-classes.
      else.

        append value #(
          info = value #( name = iv_test_method )
        ) to <ls_test_class>-methods.


      endif.

    endif.

  endmethod.



  method given_an_alert_for.

    data(ls_a_alert) = value if_saunit_internal_result_type=>ty_s_alerts_by_index(
        program_ndx = iv_program_index
        class_ndx   = iv_class_index
        method_ndx  = iv_method_index
        alerts = value #(
            ( kind = iv_alert_type )

        )


    ).

    append ls_a_alert to s_task_data-alerts_by_indicies.

  endmethod.


  method when_asking_for_results.


    o_cut = new zcl_adash_aunit_adapter(
        new zcl_adash_results_container( '' )
    ).
    data(result_container)  = o_cut->zif_aunit_results_adapater~adapt(
        aunit_task_result = s_task_data
        coverage_root_node = value #(  )

    ).
    t_results = result_container->get_adash_results_summary( ).
    t_test_method_results = result_container->get_adash_test_method_results( ).

  endmethod.


  method then_should_have_result.

    data(expected_result) = value ztbc_au_results(
         type = i_type
         name = i_name
         package_own = i_package
         parent_package  = i_parent
         total_tests = i_total
         total_success = i_passed
         total_failed = i_failed

     ).

    data(a_row) = value #(  t_results[
        type = i_type
        name = i_name

    ] optional ).

    if a_row is initial.
        fail( |{ `Could not find a result for ` }{ i_name }| ).
    endif.
    assert_equals(
        exp = i_total
        act = a_row-total_tests
        msg = `Total tests for  ` && i_name && ` not the expected.`
    ).

    assert_equals(
        exp = i_failed
        act = a_row-total_failed
        msg = `Total failed for ` && i_name && ` not the expected.`
    ).

    assert_equals(
        exp = i_passed
        act = a_row-total_success
        msg = `Total success for ` && i_name && ` not the expected.`
    ).


  endmethod.


  method then_test_method_result_is.

    if not line_exists( t_test_method_results[
        name = expected_name
        type = expected_type
        test_class = expected_test_class
        test_method = expected_test_method
        "package_own = expected_package package depends on installation (abapGit)
        status  = expected_status
    ]  ).

      fail( `Could not find expected result for ` && expected_test_class && `-` && expected_test_method ).


    endif.

  endmethod.

endclass.
