class zcl_adash_entry_info_provider definition
  public
  final
  create public .

  public section.
    class-methods:
      populate_package_data
        importing
                  entry         type zsbc_program_entry
        returning value(result) type zsbc_program_entry,
      get_last_change_info
        importing
                  entry         type zsbc_program_entry
        returning value(result) type zsbc_adash_change_info.

  protected section.
  private section.
    class-methods get_for_class
      importing
        i_entry         type zsbc_program_entry
      returning
        value(r_result) type zsbc_adash_change_info.
    class-methods get_for_others
      importing
        i_entry  type zsbc_program_entry
      changing
        c_result type zsbc_adash_change_info.
endclass.



class zcl_adash_entry_info_provider implementation.

  method populate_package_data.
    result = entry.

    if result-type eq 'DEVC'.
        select single
            devclass as package_own,
            parentcl as parent_package
        into corresponding fields of @result
        from tdevc
        where devclass = @result-name.
    else.
    select single
           program_entry~devclass as package_own,
           parent~parentcl as parent_package
        into corresponding fields of @result
        from tadir as program_entry
        left outer join tdevc as parent
        on parent~devclass = program_entry~devclass
        where program_entry~object = @entry-type
        and program_entry~obj_name = @entry-name
        .
     endif.

  endmethod.

  method get_last_change_info.

    if entry-type = 'CLAS'.
        result = get_for_class( entry ).
    else.
        get_for_others(
              exporting
                i_entry = entry
              changing
                c_result = result ).
    endif.

  endmethod.


  method get_for_class.

    data(class_info_provider) = new cl_oo_class_version_provider(
     ).

    try.
        data(active_version_ref) = class_info_provider->if_wb_object_version_provider~get_version(
            object_type                = i_entry-type
            object_name                = conv #( i_entry-name )
            version_id                 = '0000' "active
        ).

        data(active_version_data) = active_version_ref->get_info( ).

      catch cx_wb_object_versioning.
        return.
    endtry.

    r_result-change_author = active_version_data-author.
    r_result-change_date   = active_version_data-datum.
    r_result-change_id     = active_version_data-korrnum.
    r_result-change_time   = active_version_data-zeit.

  endmethod.


  method get_for_others.

    data(type) = conv versobjtyp( 'REPS' ).
    data(name) = cond versobjnam(
        when i_entry-type = 'FUGR'
        then |SAPL{ i_entry-name }|
        else i_entry-name ).

    "@TODO: for programs (PROG) and function modules (FUGR),
    "ideally, we should loop all the includes (or FMs)
    "and get what is the last one in the list

    "@TODO: clean
    data versions type table of vrsd.
    data versions_info type table of vrsn.
    call function 'SVRS_GET_VERSION_DIRECTORY_46'
      exporting
        objname      = name
        objtype      = type
      tables
        lversno_list = versions_info
        version_list = versions
      exceptions
        others       = 4.

    if sy-subrc = 0 and lines( versions ) > 0.
      sort versions by datum descending zeit descending.
      c_result-change_date = versions[ 1 ]-datum.
      c_result-change_time = versions[ 1 ]-zeit.
      c_result-change_author = versions[ 1 ]-author.
      c_result-change_id = versions[ 1 ]-korrnum.
    endif.

  endmethod.

endclass.
