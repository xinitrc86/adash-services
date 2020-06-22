class ltc_entry_info definition
for testing
duration short
risk level harmless
inheriting from zclca_assert.


  private section.
    constants:
      begin of myself,
        name type sobj_name value 'ZCL_ADASH_ENTRY_INFO_PROVIDER',
        type type trobjtype value 'CLAS',
      end of myself,
      begin of setup_runner,
        name type sobj_name value 'ZPR_ADASH_SETUP_RUNNER',
        type type trobjtype value 'PROG',
      end of setup_runner,
      begin of bg_runner,
        name type sobj_name value 'ZADASH_RUNNER_FG',
        type type trobjtype value 'FUGR',
      end of bg_runner.
    data:
      o_cut type ref to zcl_adash_entry_info_provider.
    methods:
      setup,
      teardown,
      it_populates_package_of_entry for testing,
      it_returns_last_change_clas for testing,
      it_returns_last_change_prog for testing,
      it_returns_last_change_fugr for testing.

endclass.

class ltc_entry_info implementation.

  method setup.
    o_cut = new #( ).
  endmethod.

  method teardown.

  endmethod.

  method it_populates_package_of_entry.

    data(filled) = o_cut->populate_package_data( value #(
      type = myself-type
      name = myself-name
    ) ).

    assert_char_cp(
      exporting
        act              = filled-package_own
        exp              = '*ADASH_RESULTS'
        msg = 'Should populate own package'
    ).

    assert_char_cp(
      exporting
        act              = filled-parent_package
        exp              = '*ADASH'
        msg = 'Should populate parent package'
    ).


  endmethod.

  method it_returns_last_change_clas.

    data(last) = o_cut->get_last_change_info( value #(
     type = myself-type
     name = myself-name
    ) ).


    assert_not_initial(
        act = last-change_date
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_time
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_author
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_id
        msg = 'Should return last change data' ).

  endmethod.

  method it_returns_last_change_prog.

    data(last) = o_cut->get_last_change_info( value #(
      type = setup_runner-type
      name = setup_runner-name
     ) ).


    assert_not_initial(
        act = last-change_date
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_time
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_author
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_id
        msg = 'Should return last change data' ).


  endmethod.


  method it_returns_last_change_fugr.

    data(last) = o_cut->get_last_change_info( value #(
      type = bg_runner-type
      name = bg_runner-name
     ) ).

    assert_not_initial(
        act = last-change_date
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_time
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_author
        msg = 'Should return last change data' ).

    assert_not_initial(
        act = last-change_id
        msg = 'Should return last change data' ).


  endmethod.
endclass.
