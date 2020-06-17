class ltc_results_container definition
for testing
duration short
risk level harmless
inheriting from zcl_assert.

  public section.
    constants:
      default_guid type guid_32 value 'SELFTEST',
      begin of default_test_entry,
        name           type sobj_name value 'ZCL_ADASH_RESULTS_CONTAINER',
        type           type trobjtype value 'CLAS',
        package_own    type devclass value 'ZBC_ADASH_RESULTS',
        parent_package type devclass value 'ZBC_ADASH',
      end of default_test_entry.

  private section.
    data o_cut type ref to zif_adash_results_container.


    methods:
      setup,
      it_captures_test_results for testing,
      it_sums_results_to_packages for testing,
      it_considers_existing_results for testing,
      it_captures_test_coverage for testing,
      it_captures_test_methods_resul for testing,
      "@TODO: avoid multiple adds for the same entry!!!
      then_should_have_adash_summary
        importing
          execution_guid type guid_32
          name                         type c
          total_tests                  type i optional
          total_success                type i optional
          total_failed                 type i optional
          message                      type c
          statements_covered           type i optional
          statements_count             type i optional
          statements_uncovered         type i optional
        returning
          value(adash_results_summary) type zsbc_adash_result_summary_t,
    then_test_method_results_has
      importing
          method_result TYPE ztbc_au_tests.



endclass.

class ltc_results_container implementation.


  method setup.

    o_cut =  new zcl_adash_results_container( default_guid ).

    delete from ztbc_au_results where execution = me->default_guid.
    delete from ztbc_au_tests where execution = me->default_guid.

  endmethod.

  method it_captures_test_results.

    data(result_entry) = value zsbc_test_summary(
        entry = default_test_entry
        total_tests = 100
        total_failed = 60
        total_success = 40
    ).

    o_cut->add_test_summary(
        result_entry
    ).

    then_should_have_adash_summary(
          name          = default_test_entry-name
          execution_guid  = default_guid
          total_tests   = 100
          total_failed  = 60
          total_success = 40
          message       = 'Should have captured a test summary.' ).


  endmethod.



  method it_sums_results_to_packages.
    "@ATTENTION: possible flake test depending of ABAP git instalation.

    data(result_entry) = value zsbc_test_summary(
        entry = default_test_entry
        total_tests = 100
        total_failed = 60
        total_success = 40
    ).

    o_cut->add_test_summary(
        result_entry
    ).

    data(other) = result_entry.
    other-entry-name = other-entry-name && '2'.

    o_cut->add_test_summary(
        other
    ).


    then_should_have_adash_summary(
          name          = 'ZCL_ADASH_RESULTS_CONTAINER'
          execution_guid  = default_guid
          total_tests   = 100
          total_success = 40
          total_failed  = 60
          message       = 'Should have added to self ' ).

    then_should_have_adash_summary(
          name          = 'ZBC_ADASH_RESULTS'
          execution_guid  = default_guid
          total_tests   = 200
          total_success = 80
          total_failed  = 120
          message       = 'Should have added to own package ' ).

    then_should_have_adash_summary(
          name          = 'ZBC_ADASH'
          execution_guid  = default_guid
          total_tests   = 200
          total_success = 80
          total_failed  = 120
          message       = 'Should have added to parent package ' ).


  endmethod.

  method it_considers_existing_results.
    "the idea here is that I might do a partial execution of the tests
    "but I still want the full tree updated

    data(result_entry) = value zsbc_test_summary(
        entry = default_test_entry
        total_tests = 100
        total_failed = 60
        total_success = 40
    ).


    data(existing) = value ztbc_au_results(
        execution = default_guid
        entry = default_test_entry
        total_tests = 50
        total_failed = 30
        total_success = 20
    ).

    modify ztbc_au_results from existing.


    data(existing_package) = value ztbc_au_results(
        execution = default_guid
        entry = value #(
            name = 'ZBC_ADASH_RESULTS'
            type = 'DEVC'
            package_own = 'ZBC_ADASH_RESULTS'
            parent_package = 'ZBC_ADASH' )
        total_tests = 70 "20 + from other object
        total_failed = 40 "10 + from other object
        total_success = 30 "10 + from other object
    ).

    modify ztbc_au_results from existing_package.


    data(existing_parent) = value ztbc_au_results(
        execution = default_guid
        entry = value #(
            type = 'DEVC'
            name = 'ZBC_ADASH'
            package_own = 'ZBC_ADASH'
            parent_package = 'ZBC_001' )
        total_tests = 150
        total_failed = 130
        total_success = 120
    ).

    modify ztbc_au_results from @( corresponding #( existing_parent ) ).

    o_cut->add_test_summary(
        result_entry
    ).

    then_should_have_adash_summary(
          name          = 'ZCL_ADASH_RESULTS_CONTAINER'
          execution_guid  = default_guid
          total_tests   = 100
          total_failed  = 60
          total_success = 40
          message       = 'Should have added to self ' ).

    then_should_have_adash_summary(
          name          = 'ZBC_ADASH_RESULTS'
          execution_guid  = default_guid
          total_tests   = 120
          total_failed  = 70
          total_success = 50
          message       = 'Should have added to own package entry' ).

    then_should_have_adash_summary(
          name          = 'ZBC_ADASH'
          execution_guid  = default_guid
          total_tests   = 200
          total_failed  = 160
          total_success = 140
          message       = 'Should have added to parent package ' ).


  endmethod.

  method it_captures_test_coverage.

    data(coverage_entry) = value zsbc_coverage_summary(
        entry = default_test_entry
        statements_count = 200
        statements_covered = 180
        statements_uncovered = 20
    ).


    o_cut->add_coverage_summary( coverage_entry ).


    then_should_have_adash_summary(
        name                  = default_test_entry-name
        execution_guid  = default_guid
        message               = 'Should have captured coverage'
        statements_count      = 200
        statements_covered    = 180
        statements_uncovered  = 20
    ).


    data(test_entry) = value zsbc_test_summary(
        entry = default_test_entry
        total_tests = 100
        total_failed = 60
        total_success = 40
    ).

    o_cut->add_test_summary(
        test_entry
    ).



    then_should_have_adash_summary(
        name                  = default_test_entry-name
        execution_guid  = default_guid
        message               = 'Should work together with add test sumarry'
        statements_count      = 200
        statements_covered    = 180
        statements_uncovered  = 20
        total_tests = 100
        total_success = 40
        total_failed = 60 ).


    then_should_have_adash_summary(
        name                  = default_test_entry-package_own
        execution_guid  = default_guid
        message               = 'Should have added coverage to own package'
        statements_count      = 200
        statements_covered    = 180
        statements_uncovered  = 20
        total_tests = 100
        total_success = 40
        total_failed = 60 ).


    then_should_have_adash_summary(
        name                  = default_test_entry-parent_package
        execution_guid  = default_guid
        message               = 'Should have added coverage to parent'
        statements_count      = 200
        statements_covered    = 180
        statements_uncovered  = 20
        total_tests = 100
        total_success = 40
        total_failed = 60 ).


  endmethod.

  method it_captures_test_methods_resul.

        data(a_method_result) = value ztbc_au_tests(
            name = default_test_entry-name
            type = default_test_entry-type
            test_class = 'LTC_TESTING_CLASS'
            test_method = 'IT_TEST_SOMETHING'
            status = -1
            failure_header = 'Should have tested something.'
            failure_details = 'Here goes the details of what went wrong.'
        ).

        o_cut->add_test_method_result( a_method_result ).


        data(another_method_result) = value ztbc_au_tests(
            name = default_test_entry-name
            type = default_test_entry-type
            test_class = 'LTC_TESTING_CLASS'
            test_method = 'IT_TEST_OTHER'
            status = -1
            failure_header = 'Should have tested something else .'
            failure_details = 'Here goes the details of what went wrong.'
        ).

        o_cut->add_test_method_result( another_method_result ).


        then_test_method_results_has( value #(
             base a_method_result
             package_own = 'ZBC_ADASH_RESULTS' "Should populate package data
             parent_package = 'ZBC_ADASH'
             execution = default_guid
            )

        ).

        then_test_method_results_has( value #(
             base another_method_result
             package_own = 'ZBC_ADASH_RESULTS' "Should populate package data
             parent_package = 'ZBC_ADASH'
             execution = default_guid
            )

        ).


  endmethod.


  method then_should_have_adash_summary.

    adash_results_summary  = o_cut->get_adash_results_summary( ).

    data(a_row) = value #( adash_results_summary[
        name = name
        execution   = execution_guid
    ] optional ).

    if a_row is initial.
      fail( message ).
    endif.

    if total_tests is supplied.
        assert_equals(
            exp = total_tests
            act = a_row-total_Tests
            msg = `Total tests for ` && name && ` not the expected.`
        ).
    endif.

    if total_failed is supplied.
        assert_equals(
            exp = total_failed
            act = a_row-total_failed
            msg = `Total failed for ` && name && ` not the expected.`
        ).
    endif.

    if total_success is supplied.
        assert_equals(
            exp = total_success
            act = a_row-total_success
            msg = `Total success for ` && name && ` not the expected.`
        ).
    endif.


    if statements_covered is supplied.
        assert_equals(
            exp = statements_covered
            act = a_row-statements_covered
            msg = `Covered statements for ` && name && ` not the expected.`
        ).
    endif.


    if statements_count is supplied.
        assert_equals(
            exp = statements_count
            act = a_row-statements_count
            msg = `Total statements for ` && name && ` not the expected.`
        ).
    endif.

    if statements_uncovered is supplied.
        assert_equals(
            exp = statements_uncovered
            act = a_row-statements_uncovered
            msg = `Uncovered statements for ` && name && ` not the expected.`
        ).
    endif.


  endmethod.


  method then_test_method_results_has.

    data(test_method_results) = o_cut->get_adash_test_method_results( ).


    assert_table_contains(
        line = method_result
        table = test_method_results
        msg = 'Should have stored the test method results'
    ).

  endmethod.

endclass.
