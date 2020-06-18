class ltc_results_container definition
for testing
duration short
risk level harmless
inheriting from zcl_assert.

  public section.
    data:
      self_test type guid_32 value 'SELFTEST',
      begin of default_test_entry,
        name           type sobj_name value 'ZCL_ADASH_RESULTS_CONTAINER',
        type           type trobjtype value 'CLAS',
        package_own    type devclass value 'ZADASH_RESULTS',
        parent_package type devclass value 'ZADASH',
      end of default_test_entry.

  private section.
    data o_cut type ref to zif_adash_results_container.



    methods:
      setup,
      it_captures_test_results for testing,
      it_sums_results_to_parent_pkgs for testing,
      it_considers_existing_results for testing,
      it_detects_no_coverage_run for testing,
      it_captures_test_coverage for testing,
      it_captures_test_methods_resul for testing,
      "@TODO: avoid multiple adds for the same entry!!!
      then_should_have_adash_summary
        importing
          execution_guid               type guid_32
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
          method_result type ztbc_au_tests,
      given_an_existing_result
        importing
          entry                type zsbc_program_entry
          total_tests          type i optional
          total_failed         type i optional
          statements_count     type i optional
          statements_covered   type i optional
          statements_uncovered type i optional
          total_success        type i optional.



endclass.

class ltc_results_container implementation.


  method setup.

    o_cut =  new zcl_adash_results_container( self_test ).
    default_test_entry = zcl_adash_results_container=>populate_package_data( default_test_entry ).
    delete from ztbc_au_results where execution = me->self_test.
    delete from ztbc_au_tests where execution = me->self_test.

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
          execution_guid  = self_test
          total_tests   = 100
          total_failed  = 60
          total_success = 40
          message       = 'Should have captured a test summary.' ).


  endmethod.

  method it_sums_results_to_parent_pkgs.

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
          execution_guid  = self_test
          total_tests   = 100
          total_success = 40
          total_failed  = 60
          message       = 'Should have added to self ' ).

    then_should_have_adash_summary(
          name          = default_test_entry-package_own
          execution_guid  = self_test
          total_tests   = 100
          total_success = 40
          total_failed  = 60
          message       = 'Should have added to own package ' ).

    then_should_have_adash_summary(
          name          = default_test_entry-parent_package
          execution_guid  = self_test
          total_tests   = 100
          total_success = 40
          total_failed  = 60
          message       = 'Should have added to parent package ' ).


  endmethod.

  method it_considers_existing_results.
    "the idea here is that I might do a partial execution of the tests
    "but I still want the full tree updated

    data(my_package_data) = zcl_adash_results_container=>populate_package_data( default_test_entry  ).

    "An existing run of Our tested entry, a class
    given_an_existing_result(
          entry = default_test_entry
          total_tests          = 50
          total_failed         = 30
          total_success        = 20 ).

    "The existing summary of the Package of class with results from someone else
    given_an_existing_result(
          entry = value #(
            name = my_package_data-package_own
            type = 'DEVC'
            package_own = my_package_data-package_own
            parent_package = my_package_data-parent_package )
          total_tests          = 70
          total_failed         = 40
          total_success        = 30 ).


    "But now a new execution has happened at our class
    data(new_test) = value zsbc_test_summary(
        entry = default_test_entry
        total_tests = 100
        total_failed = 60
        total_success = 40
    ).


    o_cut->add_test_summary(
        new_test
    ).


    "For our class, is our new value
    "total 100
    then_should_have_adash_summary(
          name          = default_test_entry-name
          execution_guid  = self_test
          total_tests   = 100
          total_failed  = 60
          total_success = 40
          message       = 'Should have added to self ' ).

    "For everyone else is X
    "X = my existing + delta
    "where delta = new test entry - existing result

    "x = 70 + ( 100 - 50 ) = 120
    then_should_have_adash_summary(
          name          = my_package_data-package_own
          execution_guid  = self_test
          total_tests   = 120
          total_failed  = 70
          total_success = 50
          message       = 'Should have added to own package entry' ).

    "same applies for parent packages

  endmethod.

  method it_detects_no_coverage_run.
    "first run with coverage -> count is 100
    "second run, no coverage, don't do a delta take existing -> count still 100

    data(my_package_data) = zcl_adash_results_container=>populate_package_data( default_test_entry  ).

    "An existing run of Our tested entry, a class
    given_an_existing_result(
          entry = default_test_entry
          statements_count       = 50
          statements_covered     = 30
          statements_uncovered   = 20 ).

    "The existing summary of the Package of class with results from someone else
    given_an_existing_result(
          entry = value #(
            name = my_package_data-package_own
            type = 'DEVC'
            package_own = my_package_data-package_own
            parent_package = my_package_data-parent_package )
          statements_count      = 70
          statements_covered    = 40
          statements_uncovered  = 30 ).

    "But now a new execution has happened at our class,
    "and the test summary comes first (was zero in DB)
    data(new_test) = value zsbc_test_summary(
        entry = default_test_entry
        total_tests = 12
        total_failed = 2
        total_success = 10
    ).

    o_cut->add_test_summary(
        new_test
    ).

   "now whoever is calling is deciding to add blank coverages
   "at least it is what the adapter is doing ;)

   o_cut->add_coverage_summary(
    value zsbc_coverage_summary(
        entry = default_test_entry
    )
   ).

    "What we want is to have previous run that have coverage to stay as they are
    "There is a very awkward scenario where maybe your tests aren't covering anything anymore
    "and (somehow) your tests are still passing.
    "this implementation would false accuse as covered

    then_should_have_adash_summary(
          name          = default_test_entry-name
          execution_guid  = self_test
          total_tests    = 12
          total_failed = 2
          total_success = 10
          statements_count = 50
          statements_covered = 30
          statements_uncovered = 20
          message       = 'Should keep self coverage' ).

    "For everyone else is X
    "X = my existing + delta
    "where delta = new test entry - existing result


    "x = 70 + ( 100 - 50 ) = 120
    then_should_have_adash_summary(
          name          = my_package_data-package_own
          execution_guid  = self_test
          total_tests    = 12
          total_failed = 2
          total_success = 10
          statements_count   = 70
          statements_covered  = 40
          statements_uncovered = 30
          message       = 'Should have kept parent coverage' ).

    "The same for all parents of parent of parent of parent...


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
        execution_guid  = self_test
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
        execution_guid  = self_test
        message               = 'Should work together with add test sumarry'
        statements_count      = 200
        statements_covered    = 180
        statements_uncovered  = 20
        total_tests = 100
        total_success = 40
        total_failed = 60 ).


    then_should_have_adash_summary(
        name                  = default_test_entry-package_own
        execution_guid  = self_test
        message               = 'Should have added coverage to own package'
        statements_count      = 200
        statements_covered    = 180
        statements_uncovered  = 20
        total_tests = 100
        total_success = 40
        total_failed = 60 ).


    then_should_have_adash_summary(
        name                  = default_test_entry-parent_package
        execution_guid  = self_test
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
         execution = self_test
        )

    ).

    then_test_method_results_has( value #(
         base another_method_result
         package_own = 'ZBC_ADASH_RESULTS' "Should populate package data
         parent_package = 'ZBC_ADASH'
         execution = self_test
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
          act = a_row-total_tests
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


  method given_an_existing_result.

    data(existing) = value ztbc_au_results(
        execution = self_test
        entry = entry
        total_tests = total_tests
        total_failed = total_failed
        total_success = total_success
        statements_count = statements_count
        statements_covered = statements_covered
        statements_uncovered = statements_uncovered
    ).

    modify ztbc_au_results from existing.

  endmethod.

endclass.
