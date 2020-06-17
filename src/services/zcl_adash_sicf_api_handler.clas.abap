class zcl_adash_sicf_api_handler definition
  public
  final
  create public .

  public section.
     INTERFACES if_http_extension.
  protected section.
  private section.
ENDCLASS.



CLASS ZCL_ADASH_SICF_API_HANDLER IMPLEMENTATION.


  method if_http_extension~handle_request.
    data(lo_request_handler) = new zcl_adash_api( ).
    data(lo_swagger) = new zcl_swag(
        ii_server = server
        iv_title  = 'ADASH - Abap Unit Dashboard'
        iv_base   = '/sap/zadash'
    ).
    lo_swagger->register( lo_request_handler ).
    lo_swagger->run( ).

  endmethod.
ENDCLASS.
