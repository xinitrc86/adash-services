FUNCTION ZDASH_BG_PACKAGE_RUNNER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PACKAGE) TYPE  DEVCLASS
*"     VALUE(WITH_COVERAGE) TYPE  XFLAG OPTIONAL
*"     VALUE(BREAK) TYPE  XFLAG OPTIONAL
*"----------------------------------------------------------------------
  "give us a quick feedback
  new zcl_adash_api(  )->run_tests(
      type = 'DEVC'
      component = conv #( package )
      with_coverage = with_coverage ).


  "let the coverage take its time
  if break = abap_false.
    call function 'ZDASH_BG_PACKAGE_RUNNER'
      starting new task 'ADASH_PACKAGE_FG_COV'
      exporting
        package       = package
        with_coverage = abap_true
        break         = abap_true.

  endif.

endfunction.
