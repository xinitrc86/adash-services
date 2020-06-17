interface ZIF_ADASH_RESULTS_DB_LAYER
  public .

    methods:
        persist
            importing
                results_container type ref to zif_adash_results_container
                is_subset type abap_bool default abap_false.

endinterface.
