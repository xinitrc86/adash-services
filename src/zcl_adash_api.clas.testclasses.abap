"@TODO:
class ltc_ definition
for testing
duration short
risk level harmless
inheriting from zclca_assert.

  private section.
    data:
      o_cut type ref to ZCL_ADASH_API.
    methods:
        setup,
        teardown.

endclass.

class ltc_ implementation.

    method setup.
        o_cut = new #( ).
    endmethod.

    method teardown.

    endmethod.
endclass.
