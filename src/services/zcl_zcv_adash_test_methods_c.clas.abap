class ZCL_ZCV_ADASH_TEST_METHODS_C definition
  public
  inheriting from CL_SADL_GTK_EXPOSURE_MPC
  final
  create public .

public section.
protected section.

  methods GET_PATHS
    redefinition .
  methods GET_TIMESTAMP
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZCV_ADASH_TEST_METHODS_C IMPLEMENTATION.


  method GET_PATHS.
et_paths = VALUE #(
( |CDS~ZCV_ADASH_TEST_METHODS_C| )
).
  endmethod.


  method GET_TIMESTAMP.
RV_TIMESTAMP = 20200614184904.
  endmethod.
ENDCLASS.
