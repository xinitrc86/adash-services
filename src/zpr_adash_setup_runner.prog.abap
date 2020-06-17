*&---------------------------------------------------------------------*
*& Report zbcr_adash_setup_runner
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zpr_adash_setup_runner.

parameters:
    wcov type abap_bool as checkbox.

data persistence_layer type ref to zif_adash_results_db_layer.


persistence_layer = new zcl_adash_results_db_layer( ).
data(runner) = new zcl_adash_setup_runner(
    with_coverage = wcov ).

data(results_container) = runner->run_and_return_results( ).
persistence_layer->persist( results_container ).
