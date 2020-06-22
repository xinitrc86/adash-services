class ZCL_ADASH_SETUP_RUNNER definition
  public
  inheriting from ZCL_ADASH_TEST_RUNNER_BASE
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !WITH_COVERAGE type ABAP_BOOL optional
      !GUID_FILTER type GUID_32 optional
      !AUNIT_RUNNER type ref to CL_AUCV_TEST_RUNNER_ABSTRACT optional
    preferred parameter WITH_COVERAGE .

  methods RUN_AND_RETURN_RESULTS
    redefinition .
protected section.
  private section.
    data guid_filter_range type range of guid_32.
    data adash_setups type standard table of ztbc_adash_setup.
    data with_coverage type abap_bool.
    methods prepare_filter
      importing
        guid_filter type guid_32.
    methods load_setup.
    methods has_a_parent_in_setup
      importing
        setup                   type ztbc_adash_setup
      returning
        value(parent_is_on_setup) type abap_bool.



ENDCLASS.



CLASS ZCL_ADASH_SETUP_RUNNER IMPLEMENTATION.


  method constructor.
    "@TODO: improtve this...rethink this test runner, maybe no base class is better
    super->constructor(
        aunit_runner = cond #(
            when !aunit_runner is bound then !aunit_runner
            when !with_coverage = abap_true then zcl_adash_test_runner_base=>new_coverage_runner( )
            else zcl_adash_test_runner_base=>new_no_coverage_runner( ) )
    ).
    prepare_filter( guid_filter ).
    me->with_coverage = with_coverage.
  endmethod.


  method has_a_parent_in_setup.

    data(as_package) = conv devclass( setup-name ).
    select single devclass, parentcl
    from tdevc
    into @data(parent_link)
    where devclass = @as_package.

    if sy-subrc <> 0.
      "reached rot
      parent_is_on_setup = abap_false.
      return.
    endif.

    read table adash_setups into data(found_parent)
    with key name = parent_link-parentcl
             type = 'DEVC'.

    if sy-subrc = 0
   and found_parent-max_duration_allowed = setup-max_duration_allowed
   and found_parent-max_risk_level_allowed  = setup-max_risk_level_allowed.
        parent_is_on_setup = abap_true.
        return.
    else.
        data(parent) = setup.
        parent-name = parent_link-parentcl.
        parent_is_on_setup = has_a_parent_in_setup( parent ).
    endif.

  endmethod.


  method load_setup.

    select * from ztbc_adash_setup
    into table @adash_setups
    where current_execution_guid in @me->guid_filter_range.

    loop at adash_setups assigning field-symbol(<setup_to_check>).

        data(indexCurrent) = sy-tabix.
        <setup_to_check>-with_coverage = me->with_coverage.
        data(package) =  <setup_to_check>-name.

        if has_a_parent_in_setup( <setup_to_check> ).
            delete adash_setups index indexCurrent.
        endif.

    endloop.



  endmethod.


  method prepare_filter.

    if guid_filter is not initial.
      me->guid_filter_range = value #(
          ( option = 'EQ'
          sign = 'I'
          low =  guid_filter ) ).
    endif.

  endmethod.


  method run_and_return_results.

    load_setup( ).

    loop at adash_setups into data(a_setup).
        create_run_results_container( a_setup ).
        result = run_aunit_and_adapt( a_setup ).

    endloop.


  endmethod.
ENDCLASS.
