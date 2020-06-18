class zcl_adash_component_runner definition
  public
  final
  create public
  inheriting from zcl_adash_test_runner_base.

  public section.
    methods:
      constructor
        importing
          !guid_filter   type guid_32 optional
          !component     type sobj_name
          !type          type trobjtype
          !aunit_runner  type ref to cl_aucv_test_runner_abstract optional
          !with_coverage type abap_bool default abap_false,
      run_and_return_results redefinition.

  protected section.
  private section.
    data adash_setups type standard table of ztbc_adash_setup.
    data component type sobj_name.
    data type type trobjtype.



endclass.



class zcl_adash_component_runner implementation.


  method constructor.
    "@TODO: I see this piece of code elsewhere too.
    "Create a factory
    super->constructor(
        aunit_runner = cond #(
            when !aunit_runner is bound then !aunit_runner
            when with_coverage eq abap_false then new_no_coverage_runner( )
            else new_coverage_runner( )
         )
    ).

    append value #(
         current_execution_guid = guid_filter
         name = component
         type = type
         "@doesnt really matter, the runner is what dictates that for now
         with_coverage = !with_coverage
         max_duration_allowed = if_aunit_attribute_enums=>c_duration-short
         max_risk_level_allowed = if_aunit_attribute_enums=>c_risk_level-harmless

    ) to adash_setups.

  endmethod.



  method run_and_return_results.

    loop at adash_setups into data(a_setup).

      create_run_results_container( a_setup ).
      result = run_aunit_and_adapt( a_setup ).

    endloop.


  endmethod.


endclass.
