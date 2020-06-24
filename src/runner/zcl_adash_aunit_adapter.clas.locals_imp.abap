class lcl_test_results_adapter definition.

  public section.
    constants:
      status_aborted type i  value -2,
      status_failed  type i  value -1,
      status_skipped type i  value 0,
      status_passed  type i  value 1.

    methods:
      constructor
        importing
          aunit_results     type if_saunit_internal_result_type=>ty_s_task
          results_container type ref to zif_adash_results_container,
      adapt.

  private section.
    data:
      results_container      type ref to zif_adash_results_container,
      aunit_results          type if_saunit_internal_result_type=>ty_s_task,

      current_program_index  type i,
      class_index            type i,
      method_index           type i,
      tests_text_description type ref to if_aunit_text_description.

    methods:
      new_test_summary
        importing
          tested_program type if_saunit_internal_result_type=>ty_s_program
        returning
          value(result)  type zsbc_test_summary,
      has_current_test_failed
        returning value(result) type abap_bool,
      collect_test_classes_results
        importing
          tested_program type if_saunit_internal_result_type=>ty_s_program
        changing
          test_summary   type zsbc_test_summary,
      collect_test_methods_results
        importing
          test_class   type if_saunit_internal_result_type=>ty_s_class
        changing
          test_summary type zsbc_test_summary,
      collect_failing_text_result
        changing
          test_class_result type ztbc_au_tests.

endclass.

class lcl_test_results_adapter implementation.

  method constructor.
    me->results_container = results_container.
    me->aunit_results = aunit_results.
    me->tests_text_description = cl_aunit_text_description=>get_instance( language = 'E' ).

  endmethod.

  method adapt.

    loop at me->aunit_results-programs into data(tested_program).
      current_program_index = sy-tabix.

      data(test_summary) = new_test_summary( tested_program ).


      collect_test_classes_results(
          exporting
            tested_program = tested_program
          changing
            test_summary = test_summary ).

      me->results_container->add_test_summary( test_summary ).

    endloop.

  endmethod.

  method new_test_summary.

    result  = value zsbc_test_summary(  ).
    cl_aunit_prog_info=>progname_to_tadir(
      exporting
          progname = conv #( tested_program-info-name )    " Name of program
      importing
          obj_type = result-entry-type    " Type of object in TADIR
          obj_name = result-entry-name    " Name of object in TADIR
    ).

  endmethod.

  method collect_test_classes_results.

    loop at tested_program-classes into data(test_class).
      class_index = sy-tabix.


      collect_test_methods_results(
            exporting
              test_class = test_class
            changing
              test_summary      = test_summary ).

    endloop.

  endmethod.

  method collect_test_methods_results.

    loop at test_class-methods into data(test_method).

      data(test_method_result) = corresponding ztbc_au_tests(
          test_summary-entry
      ).


      test_method_result-test_class = test_class-info-name.


      method_index = sy-tabix.
      test_method_result-test_method = test_method-info-name.

      test_summary-total_tests = test_summary-total_tests + 1.

      case has_current_test_failed( ).
        when abap_true.
          test_method_result-status = status_failed.
          test_summary-total_failed = test_summary-total_failed + 1.


          collect_failing_text_result(
                changing
                  test_class_result = test_method_result ).

        when abap_false.
          test_method_result-status = status_passed.
          test_summary-total_success = test_summary-total_success + 1.

      endcase.

      me->results_container->add_test_method_result( test_method_result ).

    endloop.

  endmethod.

  method has_current_test_failed.

    try.
        data(test_alerts) = me->aunit_results-alerts_by_indicies[
                program_ndx = current_program_index
                class_ndx = class_index
                method_ndx = method_index

            ]-alerts.
      catch cx_sy_itab_line_not_found.
        result = abap_false.
        return.
    endtry.

    result = cond #(
        when line_exists( test_alerts[ kind = 'F' ] ) then abap_true
        when line_exists( test_alerts[ kind = 'A' ] ) then abap_true
        when line_exists( test_alerts[ kind = 'E' ] ) then abap_true
        else abap_false

    ).

  endmethod.

  method collect_failing_text_result.

    loop at me->aunit_results-alerts_by_indicies[
        program_ndx = current_program_index
        class_ndx = class_index
        method_ndx = method_index ]-alerts
    into data(an_alert).

      test_class_result-failure_header = me->tests_text_description->get_string( an_alert-header ).


      loop at an_alert-text_infos into data(alert_info).
        if test_class_result-failure_details is not initial.
          test_class_result-failure_details = test_class_result-failure_details && cl_abap_char_utilities=>newline.
        endif.
        do alert_info-indent times.
          test_class_result-failure_details = test_class_result-failure_details && `  `.
        enddo.
        test_class_result-failure_details = test_class_result-failure_details && me->tests_text_description->get_string( alert_info ).
      endloop.


    endloop.

  endmethod.

endclass.

class lcl_coverage_result_adapter definition.

  public section.
    methods:
      constructor
        importing
          coverage_node     type ref to if_scv_result_node
          results_container type ref to zif_adash_results_container,
      adapt.
  private section.
    data:
      results_container type ref to zif_adash_results_container,
      coverage_node     type ref to if_scv_result_node.
    methods:
      walk
        importing
          node type ref to if_scv_result_node,
      new_coverage_summary
        importing
                  node          type ref to if_scv_result_node
        returning value(result) type zsbc_coverage_summary,
      populate_coverage_data
        importing
          node             type ref to if_scv_result_node
        changing
          coverage_summary type zsbc_coverage_summary,
    is_a_testable_program
      importing
        node               type ref to if_scv_result_node
      returning
          VALUE(is_testable) TYPE abap_bool,
    has_coverage_result
      importing
        entry                      type zsbc_coverage_summary
      returning
          VALUE(has_coverage_result) TYPE abap_bool.



endclass.

class lcl_coverage_result_adapter implementation.

  method constructor.
    me->results_container = results_container.
    me->coverage_node = coverage_node.
  endmethod.

  method adapt.
    walk( me->coverage_node ).
  endmethod.

  method walk.

    check node is bound.
    if is_a_testable_program( node ).

      data(as_entry) = new_coverage_summary( node ).

      populate_coverage_data(
            exporting
              node = node
            changing
              coverage_summary = as_entry ).

    if has_coverage_result( as_entry ).
      me->results_container->add_coverage_summary( as_entry ).
    endif.

    endif.

    loop at node->get_children( ) into data(child).
      walk( child ).
    endloop.



  endmethod.

  method new_coverage_summary.
    result  = value #( ).
    cl_aunit_prog_info=>progname_to_tadir(
      exporting
          progname = conv #( node->name )    " Name of program
      importing
          obj_type = result-entry-type    " Type of object in TADIR
          obj_name = result-entry-name    " Name of object in TADIR
    ).

  endmethod.

  method populate_coverage_data.

    data(coverage) = node->get_coverage( ce_scv_coverage_type=>statement ).
    check coverage is bound.


    coverage_summary-statements_count = coverage->get_total(  ).
    coverage_summary-statements_covered = coverage->get_executed( ).
    coverage_summary-statements_uncovered = coverage->get_not_executed(  ).


  endmethod.




  method is_a_testable_program.

    is_testable  = cond #(
   when node->subtype = 'CLAS'
     or node->subtype = 'PROG'
     or node->subtype = 'FUGR'
   then abap_true
   else abap_false
).

  endmethod.


  method has_coverage_result.

    has_coverage_result  = cond #(
when entry-statements_count <> 0
 and ( entry-statements_covered <> 0
 or entry-statements_uncovered <> 0 )
 then abap_true
 else abap_false
).

  endmethod.

endclass.
