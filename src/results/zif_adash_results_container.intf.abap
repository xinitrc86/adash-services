interface zif_adash_results_container
  public .

  methods add_test_method_result
    importing
        test_method type ztbc_au_tests.
  methods add_test_summary
    importing
      test_summary type zsbc_test_summary.
  methods add_coverage_summary
    importing
      coverage_summary type zsbc_coverage_summary.
  methods get_adash_results_summary
    returning value(results) type zsbc_adash_result_summary_t.
  methods get_adash_test_method_results
    returning value(results) type zsbc_adash_test_methods_t.



endinterface.
