class zcl_adash_db_update_factory definition
  public
  final
  create public .

  public section.
    class-methods:
        new_light_update
            returning value(result) type ref to zif_adash_results_db_layer,
        new_full_update
            returning value(result) type ref to zif_adash_results_db_layer.

  protected section.
  private section.
endclass.



class zcl_adash_db_update_factory implementation.


  method new_full_update.
    result = new zcl_adash_full_db_update( ).
  endmethod.

  method new_light_update.
    result = new zcl_adash_light_db_update( ).
  endmethod.

endclass.
