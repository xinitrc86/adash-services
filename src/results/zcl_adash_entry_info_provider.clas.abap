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
endclass.



class zcl_adash_entry_info_provider implementation.

  method populate_package_data.
    result = entry.
    select single
           program_entry~devclass as package_own,
           parent~parentcl as parent_package
        into corresponding fields of @result
        from tadir as program_entry
        left outer join tdevc as parent
        on parent~devclass = program_entry~devclass
        where program_entry~object = @entry-type
        and program_entry~obj_name = @entry-name.

  endmethod.

  method get_last_change_info.


    data(type) = cond versobjtyp(
        when entry-type = 'CLAS' then 'CPUB'
        else 'REPS' ).
    data(name) = cond versobjnam(
        when entry-type = 'FUGR'
        then |SAPL{ entry-name }|
        else entry-name ).

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
      sort versions by versno descending.
      result-change_date = versions[ 1 ]-datum.
      result-change_time = versions[ 1 ]-zeit.
      result-change_author = versions[ 1 ]-author.
      result-change_id = versions[ 1 ]-korrnum.
    endif.


  endmethod.

endclass.
