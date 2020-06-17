class lcl_dummy_aunit_runner definition
for testing
inheriting from cl_aucv_test_runner_abstract.

  public section.
    methods:
      run_for_program_keys redefinition,
      run_for_test_class_handles redefinition,
      get_used_program_keys_call
        exporting
          e_limit_on_duration_category type saunit_d_allowed_rt_duration
          e_limit_on_risk_level        type saunit_d_allowed_risk_level
          e_program_keys               type sabp_t_tadir_keys
          e_packages_to_measure        type string_sorted_table ,
      get_number_of_calls returning value(r_result) type i.


  private section.
    data limit_on_duration_category type saunit_d_allowed_rt_duration.
    data limit_on_risk_level type saunit_d_allowed_risk_level.
    data program_keys type sabp_t_tadir_keys.
    data packages_to_measure type string_sorted_table.
    data number_of_calls type i.

endclass.

class lcl_dummy_aunit_runner implementation.


  method run_for_program_keys.
    number_of_calls = number_of_calls + 1.
    limit_on_duration_category = i_limit_on_duration_category.
    limit_on_risk_level = i_limit_on_risk_level.
    program_keys = i_program_keys.
    packages_to_measure  = i_packages_to_measure.
  endmethod.

  method run_for_test_class_handles.
    number_of_calls = number_of_calls + 1.
  endmethod.

  method get_used_program_keys_call.
    e_limit_on_duration_category = limit_on_duration_category.
    e_limit_on_risk_level = limit_on_risk_level.
    e_program_keys = program_keys.
    e_packages_to_measure = packages_to_measure.

  endmethod.

  method get_number_of_calls.
    r_result = me->number_of_calls.
  endmethod.

endclass.

class lcl_dummy_adapter definition
for testing.

  public section.
    interfaces zif_aunit_results_adapater.
    methods:
      constructor
        importing
          results_container_to_return type ref to zif_adash_results_container.
  private section.
    data:
        used_aunit_results type if_saunit_internal_result_type=>ty_s_task,
        used_coverage_node type ref to if_scv_result_node,
        results_container_to_return type ref to zif_adash_results_container.


endclass.

class lcl_dummy_adapter implementation.


  method zif_aunit_results_adapater~adapt.
    me->used_aunit_results = aunit_task_result.
    me->used_coverage_node = coverage_root_node.
    result = results_container_to_return.
  endmethod.

  method constructor.
    me->results_container_to_return = results_container_to_return.
  endmethod.

endclass.

class lcl_dummy_node definition.

    public section.
        interfaces if_scv_result_node.

endclass.

class lcl_dummy_node implementation.

  method if_scv_result_node~belongs_to_result.

  endmethod.

  method if_scv_result_node~disable.

  endmethod.

  method if_scv_result_node~enable.

  endmethod.

  method if_scv_result_node~find_child.

  endmethod.

  method if_scv_result_node~get_children.

  endmethod.

  method if_scv_result_node~get_coverage.

  endmethod.

  method if_scv_result_node~get_coverages.

  endmethod.

  method if_scv_result_node~get_depth.

  endmethod.

  method if_scv_result_node~get_parent.

  endmethod.

  method if_scv_result_node~get_result.

  endmethod.

  method if_scv_result_node~get_root_node.

  endmethod.

  method if_scv_result_node~get_source.

  endmethod.

  method if_scv_result_node~get_statement_infos.

  endmethod.

  method if_scv_result_node~has_children.

  endmethod.

  method if_scv_result_node~is_enabled.

  endmethod.

endclass.
