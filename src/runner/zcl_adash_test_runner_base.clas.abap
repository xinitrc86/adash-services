class zcl_adash_test_runner_base definition
  public
  abstract
  create public .

  public section.
    methods:
      constructor
        importing
          aunit_runner  type ref to cl_aucv_test_runner_abstract optional,
       run_and_return_results
        abstract
        returning value(result) type ref to zif_adash_results_container.
    class-methods:
        new_coverage_runner
          returning value(aunit_runner) type ref to cl_aucv_test_runner_abstract,
        new_no_coverage_runner
          returning value(aunit_runner) type ref to cl_aucv_test_runner_abstract.


protected section.
    methods run_aunit_and_adapt
      importing
        setup         type ztbc_adash_setup
      returning
        value(result) type ref to zif_adash_results_container
      raising
        cx_scv_call_error.
    methods run_aunit_n_extract_result
      importing
        setup           type ztbc_adash_setup
      exporting
        e_aunit_results type ref to if_saunit_internal_result
        e_root_node     type ref to if_scv_result_node
      raising
        cx_scv_call_error.
    methods adapt_to_adash
      importing
        aunit_results type ref to if_saunit_internal_result
        root_node     type ref to if_scv_result_node
      returning
        value(result) type ref to zif_adash_results_container.
    methods create_run_results_container
      importing
        setup type ztbc_adash_setup.
  private section.
    data aunit_runner type ref to cl_aucv_test_runner_abstract.
    data adash_adapter type ref to zif_aunit_results_adapater.
    data results_container type ref to zif_adash_results_container.

ENDCLASS.



CLASS ZCL_ADASH_TEST_RUNNER_BASE IMPLEMENTATION.


  method adapt_to_adash.

    data(aunit_task_data) = cond #(
        when aunit_results is bound then
        cast cl_saunit_internal_result( aunit_results )->f_task_data
        else value #(  ) ).


    "@TODO: remove hard dependency, redesign to testable design
    me->adash_adapter = new zcl_adash_aunit_adapter( me->results_container ).

    result = me->adash_adapter->adapt(
          aunit_task_result  = aunit_task_data
          coverage_root_node = root_node
   ).

  endmethod.

  method constructor.
    assert aunit_runner is bound.
    me->aunit_runner = aunit_runner.
  endmethod.

  method create_run_results_container.

    me->results_container = cond #(
        when me->results_container is bound then me->results_container
        else new zcl_adash_results_container(
            execution_guid = setup-current_execution_guid )
    ).

  endmethod.


  method new_no_coverage_runner.

    aunit_runner = new zcl_adash_aunit_no_coverage(  ).

  endmethod.

  method new_coverage_runner.

      data passport    type ref to object.
      call method ('\PROGRAM=SAPLSAUCV_GUI_RUNNER\CLASS=PASSPORT')=>get
        receiving
          result = passport.

      aunit_runner = cl_aucv_test_runner_coverage=>create( passport ).

  endmethod.

  method run_aunit_and_adapt.


    run_aunit_n_extract_result(
          exporting
            setup = setup
          importing
            e_aunit_results = data(aunit_results)
            e_root_node     = data(root_node)  ).

    result = adapt_to_adash(
          aunit_results = aunit_results
          root_node     = root_node ).

  endmethod.

  method run_aunit_n_extract_result.

    data(own_package) = zcl_adash_entry_info_provider=>populate_package_data(
        value #(
            type = setup-type
            name = setup-name
        )
    )-package_own.

    aunit_runner->run_for_program_keys(
      exporting
        i_limit_on_duration_category = setup-max_duration_allowed
        i_limit_on_risk_level        = setup-max_risk_level_allowed
        "Package to run tests
        i_program_keys               = value #(
            (   obj_type = setup-type
                obj_name = setup-name
            )
        )
        "@TODO: get_package_for_measure
        i_packages_to_measure        = cond #(
            when setup-with_coverage eq abap_true
            then value #( ( conv #( own_package ) ) )
            else value #(  ) )
      importing
        e_coverage_result            = data(coverage_results)
        e_aunit_result               = e_aunit_results
    ).


    try.
        data(coverage) = coverage_results->build_coverage_result(  ).
        e_root_node  = coverage->get_root_node( ).
      catch cx_scv_execution_error cx_sy_ref_is_initial.
        e_root_node = new lcl_dummy_node( ).
    endtry.

  endmethod.
ENDCLASS.
