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
    CONSTANTS TYPE_PACKAGE TYPE string VALUE 'DEVC' ##NO_TEXT.
    methods getsetup
      importing
                i_type            type trobjtype
                i_component       type sobj_name
                i_with_coverage   type any optional
      returning value(r_newsetup) type ztbc_adash_setup.
    methods filter_parents_n_sub_subnodes
      importing
        i_setup    type ztbc_adash_setup
      changing
        c_response type zsbc_adash_api_test_response.
    methods list_my_level_only
      importing
        i_setup    type ztbc_adash_setup
      changing
        c_response type zsbc_adash_api_test_response.
    methods delete_objects_from_subnodes
      importing
        setup    type ztbc_adash_setup
      changing
        response type zsbc_adash_api_test_response.
    methods list_packages_first
      changing
        response type zsbc_adash_api_test_response.
    methods prepare_package_response
      importing
        setup    type ztbc_adash_setup
      changing
        response type zsbc_adash_api_test_response.
    methods set_status
      changing
        response type zsbc_adash_api_test_response.
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
    set_status(
          changing
            response = response ).


    data(persistence_layer) = cast zif_adash_results_db_layer( new zcl_adash_results_db_layer(  ) ).
    persistence_layer->persist(
        results_container = results ).

    if setup-type = TYPE_PACKAGE.
        prepare_package_response(
              exporting
                setup = setup
              changing
                response = response ).
    endif.



  endmethod.

  method add_for_tests.


    data(setup) = getsetup(
            i_type      = type
            i_component = component
            i_with_coverage = abap_true  ).

    modify ztbc_adash_setup from setup.

    if setup-type = TYPE_PACKAGE.
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


  method filter_parents_n_sub_subnodes.

    delete c_response-sumaries
       "parent packages
        where ( type = 'DEVC '
         and parent_package <> i_setup-name
         and package_own <> i_setup-name  ).

  endmethod.


  method list_my_level_only.

    filter_parents_n_sub_subnodes(
          exporting
            i_setup = i_setup
          changing
            c_response = c_response ).

  endmethod.


  method delete_objects_from_subnodes.

    delete response-sumaries
       where ( parent_package = setup-name
               and type <> type_package
          ).

  endmethod.


  method list_packages_first.

    data(not_packages) = value zsbc_adash_result_summary_t(
      for summary in response-sumaries
          where ( type <> type_package )
          ( summary )
   ).

    delete response-sumaries where type <> type_package.
    sort response-sumaries by name ascending.
    append lines of not_packages to response-sumaries.

  endmethod.


  method prepare_package_response.

    list_my_level_only(
          exporting
            i_setup = setup
          changing
            c_response = response ).


    delete_objects_from_subnodes(
          exporting
            setup = setup
          changing
            response = response ).

    list_packages_first(
          changing
            response = response ).

  endmethod.


  method set_status.

    response-status = cond #(
        when response-tests is initial then 0 "neutral
        when value #( response-tests[ status = -1 ] optional )
        is initial
        then 1 "passed
        else -1 "failed
    ).

  endmethod.

endclass.
