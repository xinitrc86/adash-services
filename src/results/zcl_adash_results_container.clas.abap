class zcl_adash_results_container definition
  public
  final
  create public .

  public section.
    interfaces zif_adash_results_container.


    methods constructor
      importing
        execution_guid type guid_32.


  protected section.
  private section.
    data adash_results type zsbc_adash_result_summary_t.
    data test_method_results type zsbc_adash_test_methods_t.
    data my_execution_guid type guid_32.
    data last_change_computed type zsbc_adash_change_info.

    methods add_summary_to_parent_pkg
      importing
        delta_summary  type zsbc_test_summary optional
        coverage_delta type zsbc_coverage_summary optional
        package_to_add type ztbc_au_results-package_own.
    methods compute_delta_to_adash_result
      importing
        i_delta_summary         type zsbc_test_summary optional
        i_coverage_delta        type zsbc_coverage_summary optional
      returning
        value(entry_computed) type ztbc_au_results.
    methods get_current_value
      importing
        delta_summary         type zsbc_test_summary optional
        coverage_summary      type zsbc_coverage_summary optional
      changing
        value(entry_computed) type ztbc_au_results.
    methods get_test_summary_as_own_delta
      importing
        test_summary         type zsbc_test_summary
      returning
        value(delta_summary) type zsbc_test_summary.
    methods get_coverage_as_own_delta
      importing
        coverage_summary     type zsbc_coverage_summary
      returning
        value(delta_summary) type zsbc_coverage_summary.
    methods populate_change_data
      importing
        i_entry_computed_key type zsbc_test_summary-entry
      changing
        c_entry_computed     type ztbc_au_results.

endclass.



class zcl_adash_results_container implementation.

  method zif_adash_results_container~add_test_summary.

    data(delta_summary) = get_test_summary_as_own_delta( test_summary ).

    data(entry_computed) = compute_delta_to_adash_result(
        i_delta_summary = delta_summary ).

    check entry_computed-package_own is not initial.

    add_summary_to_parent_pkg(
          delta_summary = delta_summary
          package_to_add   = entry_computed-package_own ).


  endmethod.

  method zif_adash_results_container~add_coverage_summary.

    "as opposed to tests, we allow previous values
    "to exist, not taking zeros as new.
    "this is to prevent no coverage runs to erase
    "coverage results, simply not calling this method do the trick too though...
    check coverage_summary-statements_count <> 0
    and ( coverage_summary-statements_covered <> 0
    or coverage_summary-statements_uncovered <> 0 ).


    data(delta_summary) = get_coverage_as_own_delta( coverage_summary ).

    data(entry_computed) = compute_delta_to_adash_result(
        i_coverage_delta = delta_summary ).

    add_summary_to_parent_pkg(
          coverage_delta = delta_summary
          package_to_add   = entry_computed-package_own ).


  endmethod.

  method zif_adash_results_container~add_test_method_result.

    data(with_package) = test_method.
    with_package-entry = zcl_adash_entry_info_provider=>populate_package_data( with_package-entry ).
    with_package-execution = my_execution_guid.
    append with_package to test_method_results.

  endmethod.

  method zif_adash_results_container~get_adash_results_summary.
    results = me->adash_results.
  endmethod.

  method zif_adash_results_container~get_adash_test_method_results.
    results = test_method_results.
  endmethod.

  method add_summary_to_parent_pkg.

    if delta_summary is supplied.


      data(package_test_summary) = value zsbc_test_summary( base corresponding #( delta_summary )
              entry = value #(
                  name = package_to_add
                  type = 'DEVC'
              )
          ).
    endif.

    if coverage_delta is supplied.

      data(package_coverage_summary) = value zsbc_coverage_summary( base corresponding #( coverage_delta )
               entry = value #(
                   name = package_to_add
                   type = 'DEVC'
               )
           ).
    endif.

    data(entry_computed) = compute_delta_to_adash_result(
        i_delta_summary = package_test_summary
        i_coverage_delta = package_coverage_summary
     ).

    check entry_computed-parent_package is not initial.

    add_summary_to_parent_pkg(
        delta_summary = delta_summary
        coverage_delta = coverage_delta
        package_to_add   = entry_computed-parent_package
    ).


  endmethod.

  method compute_delta_to_adash_result.

    if i_delta_summary-entry is not initial.

      entry_computed  = value #( me->adash_results[
          name = i_delta_summary-entry-name
          type = i_delta_summary-entry-type ] optional ).

      data(entry_computed_key) = i_delta_summary-entry.

    elseif i_coverage_delta-entry is not initial.

      entry_computed_key = i_coverage_delta-entry.
      entry_computed  = value #( me->adash_results[
          name = i_coverage_delta-entry-name
          type = i_coverage_delta-entry-type ] optional ).

    endif.

    get_current_value(
        exporting
            delta_summary    = i_delta_summary
            coverage_summary = i_coverage_delta
        changing
            entry_computed = entry_computed
    ).

    entry_computed-execution = my_execution_guid.

    entry_computed-total_tests = entry_computed-total_tests + i_delta_summary-total_tests.
    entry_computed-total_success = entry_computed-total_success + i_delta_summary-total_success.
    entry_computed-total_failed = entry_computed-total_failed + i_delta_summary-total_failed.

    entry_computed-statements_count = entry_computed-statements_count + i_coverage_delta-statements_count.
    entry_computed-statements_covered = entry_computed-statements_covered + i_coverage_delta-statements_covered.
    entry_computed-statements_uncovered = entry_computed-statements_uncovered + i_coverage_delta-statements_uncovered.

    populate_change_data(
          exporting
            i_entry_computed_key = entry_computed_key
          changing
            c_entry_computed = entry_computed ).

    if entry_computed-entry is not initial.
      "It might have changed places!
      move-corresponding zcl_adash_entry_info_provider=>populate_package_data( entry_computed-entry ) to entry_computed.
      modify table me->adash_results from entry_computed.
    else.
      "It might have changed places!
      move-corresponding entry_computed_key to entry_computed-entry.
      move-corresponding zcl_adash_entry_info_provider=>populate_package_data( entry_computed-entry ) to entry_computed.

      insert entry_computed into table me->adash_results.
    endif.




  endmethod.

  method constructor.
    me->my_execution_guid = execution_guid.
  endmethod.

  method get_current_value.
    if delta_summary is supplied.

      select single * from ztbc_au_results
        into @data(was)
        where name = @delta_summary-entry-name
        and type = @delta_summary-entry-type
        and execution = @me->my_execution_guid.

    endif.

    if coverage_summary is supplied.

      select single * from ztbc_au_results
        into @was
        where name = @coverage_summary-entry-name
        and type = @coverage_summary-entry-type
        and execution = @me->my_execution_guid.

    endif.

    "not in the db, mewaning new entry
    if was is initial.

      "no deal, computed = delta, is a new entry of a testable
      if entry_computed is initial.
        entry_computed-statements_count  = 0.
        entry_computed-statements_covered = 0.
        entry_computed-statements_uncovered = 0.
        entry_computed-total_tests  = 0.
        entry_computed-total_success = 0.
        entry_computed-total_failed = 0.
      else.
        "maybe now its a package entry receiving results of testables!
        entry_computed-total_tests  = entry_computed-total_tests.
        entry_computed-total_success = entry_computed-total_success.
        entry_computed-total_failed = entry_computed-total_failed.
        entry_computed-statements_count  = entry_computed-statements_count.
        entry_computed-statements_covered = entry_computed-statements_covered.
        entry_computed-statements_uncovered = entry_computed-statements_uncovered.

      endif.

    else. "it has a past

      if entry_computed is initial.
        "no deal, current will is past.
        entry_computed-statements_count  = was-statements_count.
        entry_computed-statements_covered = was-statements_covered .
        entry_computed-statements_uncovered = was-statements_uncovered.
        entry_computed-total_tests  = was-total_tests.
        entry_computed-total_success = was-total_success.
        entry_computed-total_failed = was-total_failed.
      else.
        "maybe now its a package receiving results of others!
        entry_computed-total_tests  = entry_computed-total_tests.
        entry_computed-total_success = entry_computed-total_success.
        entry_computed-total_failed = entry_computed-total_failed.
        entry_computed-statements_count  = entry_computed-statements_count.
        entry_computed-statements_covered = entry_computed-statements_covered.
        entry_computed-statements_uncovered = entry_computed-statements_uncovered.

      endif.

    endif.

  endmethod.


  method get_test_summary_as_own_delta.

    select single * from ztbc_au_results
    into @data(was)
    where name = @test_summary-entry-name
    and type = @test_summary-entry-type
    and execution = @me->my_execution_guid.


    delta_summary  = test_summary. "new
    delta_summary-total_tests = test_summary-total_tests - was-total_tests.
    delta_summary-total_failed = test_summary-total_failed - was-total_failed.
    delta_summary-total_success = test_summary-total_success - was-total_success.

  endmethod.


  method get_coverage_as_own_delta.

    select single * from ztbc_au_results
    into @data(was)
    where name = @coverage_summary-entry-name
    and type = @coverage_summary-entry-type
    and execution = @me->my_execution_guid.


    delta_summary  = coverage_summary. "new
    delta_summary-statements_count = coverage_summary-statements_count - was-statements_count.
    delta_summary-statements_covered = coverage_summary-statements_covered - was-statements_covered.
    delta_summary-statements_uncovered = coverage_summary-statements_uncovered - was-statements_uncovered.

  endmethod.


  method populate_change_data.

    if i_entry_computed_key-type = 'DEVC'.
      if last_change_computed >= c_entry_computed-last_change.
        c_entry_computed-last_change = last_change_computed.
      endif.

    else.

      last_change_computed = zcl_adash_entry_info_provider=>get_last_change_info( corresponding #( i_entry_computed_key ) ).
      c_entry_computed-last_change = last_change_computed.

    endif.

  endmethod.

endclass.
