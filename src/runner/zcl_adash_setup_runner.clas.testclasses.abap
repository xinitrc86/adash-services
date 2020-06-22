"@ATTENTION: Tests are component testing,
"real aunit test run and results
class ltc_setup_runner definition
for testing duration short
risk level harmless
inheriting from zcl_assert.

  private section.
    data:
      cut                type ref to zcl_adash_setup_runner,
      dummy_aunit_runner type ref to lcl_dummy_aunit_runner,
      adash_setups       type table of ztbc_adash_setup,
      mock_result_container type ref to zcl_adash_results_container,
      dummy_adapter type ref to lcl_dummy_adapter.

    methods:
      setup,
      teardown,
      it_runs_all_setup_records for testing,
      it_avoids_tree_double_run for testing,
      it_adapts_results for testing,
      given_an_adash_setup
        importing
          i_execution_guid type c
          i_package        type c
          i_max_risk       type saunit_D_Attribute_Risk_Level
          i_max_duration   type saunit_d_attribute_rt_duration,
    then_aunit_runner_is_called_w
      importing
        expected_type         type c
        expected_name         type c
        expected_max_duration type saunit_d_attribute_rt_duration
          expected_max_risk     TYPE saunit_D_Attribute_Risk_Level
          num_calls TYPE any OPTIONAL.

endclass.

class ltc_setup_runner implementation.

  method setup.
    dummy_aunit_runner = new lcl_dummy_aunit_runner( ).
    cut = new #(
        guid_filter = 'SELFTEST'
        aunit_runner = dummy_aunit_runner
    ).    delete from ztbc_adash_setup where current_execution_guid = 'SELFTEST'.
    delete from ztbc_au_results where execution = 'SELFTEST'.
    delete from ztbc_au_tests where execution = 'SELFTEST'.
  endmethod.

  method teardown.
  endmethod.

  method it_runs_all_setup_records.


    given_an_adash_setup(
          i_execution_guid = 'SELFTEST'
          i_package        = 'ZBC_ADASH'
          i_max_risk       = if_Aunit_Attribute_Enums=>c_risk_level-harmless
          i_max_duration   = if_Aunit_Attribute_Enums=>c_Duration-short ).


    "to assert it runs multiple setups in a loop
    given_an_adash_setup(
          i_execution_guid = 'SELFTEST'
          i_package        = 'OTHER_PACKAGE'
          i_max_risk       = if_Aunit_Attribute_Enums=>c_risk_level-harmless
          i_max_duration   = if_Aunit_Attribute_Enums=>c_Duration-short ).


    data(results_container) = cut->run_and_return_results( ).

    then_aunit_runner_is_called_w(
          expected_type         = 'DEVC'
          expected_name         = 'OTHER_PACKAGE'
          expected_max_duration = if_Aunit_Attribute_Enums=>c_Duration-short
          expected_max_risk     = if_Aunit_Attribute_Enums=>c_risk_level-harmless ).

    assert_true(
        act = results_container->is_full_run( )
        msg = 'A run of all setups should be considered a full run.'
    ).

  endmethod.

  method it_adapts_results.

   "@TODO: breaking the dependency with the container
   "Doing may lead to have weird behaviors during setup run with the same package
   "running twice (with diff settings)
    cut = new #(
        guid_filter = 'SELFTEST'
        aunit_runner = new zcl_adash_aunit_no_coverage( )
    ).

    given_an_adash_setup(
          i_execution_guid = 'SELFTEST'
          i_package        = 'ZBC_ADASH_RESULTS'
          i_max_risk       = if_Aunit_Attribute_Enums=>c_risk_level-critical
          i_max_duration   = if_Aunit_Attribute_Enums=>c_Duration-long ).


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

    if num_calls is supplied.
        assert_equals(
            exp = num_calls
            act = dummy_aunit_runner->get_number_of_calls(  )
        ).

    endif.

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

    assert_initial(
      act = packages_to_measure
      msg = 'For not having long executions for THIS test, it should skip coverage'
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

  method it_avoids_tree_double_run.

        given_an_adash_setup(
            i_execution_guid = 'SELFTEST'
            i_package        =  'ROOT'
            i_max_risk       = if_Aunit_Attribute_Enums=>c_risk_level-harmless
            i_max_duration   = if_Aunit_Attribute_Enums=>c_Duration-short
        ).

        given_an_adash_setup(
            i_execution_guid = 'SELFTEST'
            i_package        =  'SUBNODE'
            i_max_risk       = if_Aunit_Attribute_Enums=>c_risk_level-harmless
            i_max_duration   = if_Aunit_Attribute_Enums=>c_Duration-short
        ).


        data(node_link_to_root) = value tdevc(
            devclass = 'NODE'
            parentcl = 'ROOT'
        ).

        modify tdevc from node_link_to_root.

        data(subnode_link_to_node) = value tdevc(
            devclass = 'SUBNODE'
            parentcl = 'NODE'
        ).

        modify tdevc from subnode_link_to_node.

        cut->run_and_return_results(  ).

        then_aunit_runner_is_called_w(
          num_calls             = 1
          expected_type         = 'DEVC'
          expected_name         = 'ROOT'
          expected_max_duration = if_Aunit_Attribute_Enums=>c_Duration-short
          expected_max_risk     = if_Aunit_Attribute_Enums=>c_risk_level-harmless ).


  endmethod.

endclass.
