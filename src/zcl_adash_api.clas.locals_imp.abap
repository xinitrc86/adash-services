class lcl_dummy_runner definition create private
inheriting from zcl_adash_test_runner_base.

  public section.
    METHODS: run_and_return_results REDEFINITION.

  protected section.
  private section.

endclass.

class lcl_dummy_runner implementation.

  method run_and_return_results.

  endmethod.

endclass.
