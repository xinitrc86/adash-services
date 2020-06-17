interface zif_aunit_results_adapater
  public .

  methods
    adapt
      importing
                aunit_task_result  type if_saunit_internal_result_type=>ty_s_task
                coverage_root_node type ref to if_scv_result_node
      returning value(result)      type ref to zif_adash_results_container.

endinterface.
