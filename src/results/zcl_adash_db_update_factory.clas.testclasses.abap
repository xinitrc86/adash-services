class ltc_ definition
for testing
duration short
risk level harmless
inheriting from zclca_assert.

  private section.
    data:
      o_cut type ref to ZCL_ADASH_DB_UPDATE_FACTORY.
    methods:
        setup,
        teardown,
        it_returns_a_light_update for testing,
        it_returns_the_full_updt for testing.
        "it_returns_keep_hist ...

endclass.

class ltc_ implementation.

    method setup.
        o_cut = new #( ).
    endmethod.

    method teardown.

    endmethod.

  method it_returns_a_light_update.

    data(db_update) = o_cut->new_light_update(  ).


    "The light update will simply right results to the db
    "and delete entries that were deleted, but it does not
    "compare the result set with the db.
    if not db_update is instance of zcl_adash_light_db_update.
        fail( 'No coverage runs represent a light update.').
    endif.


  endmethod.

  method it_returns_the_full_updt.

    data(db_update) = o_cut->new_full_update( ).


    "So far we rely on the coverage run (+ the adapter) to probe
    "the system for objects. This is the only run that has the full
    "list of objects that are monitored.
    "The full run takes care of things such as objects that are renamed,
    "and for that it compares what is on DB.
    if not db_update is instance of zcl_adash_full_db_update.
        fail( 'No coverage runs represent a full update.').
    endif.


  endmethod.

endclass.
