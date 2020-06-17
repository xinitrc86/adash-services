class zcl_adash_aunit_adapter definition
  public
  final
  create public .

  public section.
    interfaces zif_aunit_results_adapater.
    methods:
      constructor
        importing
            results_container type ref to zif_adash_results_container optional.

  protected section.
  private section.
    data:
      results_container      type ref to zif_adash_results_container.

    methods:
      adapt_aunit_results_to_adash
        importing
          aunit_results type if_saunit_internal_result_type=>ty_s_task,

    adapt_aunit_coverage_to_adash
      importing
          coverage_root_node TYPE REF TO if_scv_result_node,

    lookup_container_dependency
      importing
          results_container TYPE REF TO zif_adash_results_container.
ENDCLASS.



CLASS ZCL_ADASH_AUNIT_ADAPTER IMPLEMENTATION.


  method adapt_aunit_coverage_to_adash.

    new lcl_coverage_result_adapter(
        coverage_node     = coverage_root_node
        results_container = me->results_container
    )->adapt(  ).

  endmethod.


  method adapt_aunit_results_to_adash.

    new lcl_test_results_adapter(
        results_container = me->results_container
        aunit_results     = aunit_results
    )->adapt( ).


  endmethod.


  method constructor.
    lookup_container_dependency( results_container ).
  endmethod.


  method lookup_container_dependency.

    me->results_container = cond #( when results_container is bound then results_container
    else new zcl_adash_results_container( 'TEMP'  ) ).

  endmethod.


  method zif_aunit_results_adapater~adapt.
    adapt_aunit_results_to_adash( aunit_task_result ).
    adapt_aunit_coverage_to_adash( coverage_root_node ).
    result = me->results_container.
  endmethod.
ENDCLASS.
