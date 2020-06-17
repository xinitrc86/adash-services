"@ATTENTION: Tests are component testing,
"real aunit test run and results
class ltc_component_runner definition
for testing duration short
risk level harmless
inheriting from zcl_assert.

  private section.

    data:
      cut                   type ref to zcl_adash_component_runner,
      dummy_aunit_runner    type ref to lcl_dummy_aunit_runner,
      adash_setups          type table of ztbc_adash_setup,
      mock_result_container type ref to zcl_adash_results_container,
      dummy_adapter         type ref to lcl_dummy_adapter.

    methods:
      setup,
      teardown,
      it_runs_setup_records for testing,
      it_adapts_results for testing,
      given_an_adash_setup
        importing
          i_execution_guid type c
          i_package        type c
          i_max_risk       type saunit_d_attribute_risk_level
          i_max_duration   type saunit_d_attribute_rt_duration,
      then_aunit_runner_is_called_w
        importing
          expected_type         type c
          expected_name         type c
          expected_max_duration type saunit_d_attribute_rt_duration
          expected_max_risk     type saunit_d_attribute_risk_level.

endclass.

class ltc_component_runner implementation.

  method setup.
    dummy_aunit_runner = new lcl_dummy_aunit_runner( ).
    cut = new #(
       guid_filter = 'SELFTEST'
       component    = 'ZCL_ADASH_AUNIT_ADAPTER'
       type     = 'CLAS'
        aunit_runner = dummy_aunit_runner
    ).
  endmethod.

  method teardown.
  endmethod.

  method it_runs_setup_records.


    cut->run_and_return_results( ).

    then_aunit_runner_is_called_w(
          expected_type         = 'CLAS'
          expected_name         = 'ZCL_ADASH_AUNIT_ADAPTER'
          expected_max_duration = if_aunit_attribute_enums=>c_duration-short
          expected_max_risk     = if_aunit_attribute_enums=>c_risk_level-harmless ).

  endmethod.

  method it_adapts_results.

    cut = new #(
       guid_filter = 'SELFTEST'
       component     = 'ZCL_ADASH_AUNIT_ADAPTER'
       type = 'CLAS'
       with_coverage = abap_false
    ).
    "@ATTENTION:
    " flake, unsure why some netweaver versions runs coverage for other objects"
    "running the tests directly in ZBC_ADASH_RESULTS are instant
    data(results) = cut->run_and_return_results( ).


    assert_not_initial(
        act = results->get_adash_results_summary( )
        msg = 'Should have summarized results to adash'
    ).

    assert_not_initial(
        act = results->get_adash_test_method_results( )
        msg = 'Should have collected test method results.'
    ).


  endmethod.



  method given_an_adash_setup.

    data(adash_setup) = value ztbc_adash_setup(
        current_execution_guid = i_execution_guid
        name = i_package
        type = 'DEVC'
        max_duration_allowed = i_max_duration
        max_risk_level_allowed = i_max_risk
    ).

    append adash_setup to adash_setups.
    modify ztbc_adash_setup from table adash_setups.

  endmethod.


  method then_aunit_runner_is_called_w.

    dummy_aunit_runner->get_used_program_keys_call(
      importing
        e_limit_on_duration_category = data(duration_limit)
        e_limit_on_risk_level = data(risk_limit)
        e_program_keys               = data(program_keys)
        e_packages_to_measure = data(packages_to_measure)
    ).

    assert_equals(
     exp  = expected_max_duration
     act = duration_limit
     msg = 'Should have used setup max duration setting.'
    ).

    assert_equals(
     exp  = expected_max_risk
     act = risk_limit
     msg = 'Should have used setup max duration setting.'
    ).

    assert_table_contains(
         line = value sabp_s_tadir_key(
             obj_type =  expected_type
             obj_name = expected_name
         )
         table = program_keys
         msg = 'Did not found expected program key'
     ).

  endmethod.

endclass.
