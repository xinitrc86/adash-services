class zcl_adash_api definition
  public
  final
  create public .

  public section.
    interfaces zif_swag_handler.

    methods run_tests
      importing
                !type           type trobjtype
                !component      type sobj_name
                !with_coverage  type abap_bool
      returning value(response) type zsbc_adash_api_test_response.

    methods add_for_tests
      importing
        !type      type trobjtype
        !component type sobj_name.



  protected section.
  private section.
    methods getsetup
      importing
                i_type            type trobjtype
                i_component       type sobj_name
                i_with_coverage   type any optional
      returning value(r_newsetup) type ztbc_adash_setup.
endclass.



class zcl_adash_api implementation.

  method zif_swag_handler~meta.

    append value #(
        summary = 'Execute tests on given a given component and return results'
        url-regex = '/(\w*)/(\w*)/test'
        url-group_names = value #(
            ( 'TYPE' )
            ( 'COMPONENT' )
        )
        method = zcl_swag=>c_method-get
        handler = 'RUN_TESTS'

    ) to rt_meta.

    append value #(
        summary = 'Add a component for monitoring'
        url-regex = '/(\w*)/(\w*)/add'
        url-group_names = value #(
            ( 'TYPE' )
            ( 'COMPONENT' )
        )
        method = zcl_swag=>c_method-get
        handler = 'ADD_FOR_TESTS'
    ) to rt_meta.

  endmethod.


  method run_tests.

    data(setup) = getsetup(
              i_type      = type
              i_component = component
              i_with_coverage = with_coverage  ).

    data(runner) = new zcl_adash_component_runner(
       guid_filter  = setup-current_execution_guid
       component      = setup-name
       type      = setup-type
       with_coverage = setup-with_coverage
    ).

    data(results) = runner->run_and_return_results( ).
    response-tests = results->get_adash_test_method_results(  ).
    response-sumaries = results->get_adash_results_summary(  ).
    response-status = cond #(
        when value #( response-tests[ status = -1 ] optional )
        is initial
        then 1
        else -1
    ).


    data(persistence_layer) = cast zif_adash_results_db_layer( new zcl_adash_results_db_layer(  ) ).
    persistence_layer->persist(
        results_container = results ).

  endmethod.

  method add_for_tests.


    data(setup) = getsetup(
            i_type      = type
            i_component = component
            i_with_coverage = abap_true  ).

    modify ztbc_adash_setup from setup.

    if setup-type = 'DEVC'.
      data(as_package) = conv devclass( setup-name ).
      call function 'ZDASH_BG_PACKAGE_RUNNER'
        starting new task 'ADASH_PACKAGE_FG'
        exporting
          package = as_package.
    endif.


    return.

  endmethod.


  method getsetup.

    data(upper_type)  = |{ !i_type case = upper }|.
    data(upper_name)  = |{ !i_component case = upper }|.

    r_newsetup  = value ztbc_adash_setup(
        current_execution_guid = 'LAST'
        name = upper_name
        type = upper_type
       "@TODO: from api param
       keep_history = '' "experimental
       with_coverage = i_with_coverage
       "playing safe
       max_duration_allowed = if_aunit_attribute_enums=>c_duration-short
       max_risk_level_allowed = if_aunit_attribute_enums=>c_risk_level-harmless
    ).

  endmethod.

endclass.
