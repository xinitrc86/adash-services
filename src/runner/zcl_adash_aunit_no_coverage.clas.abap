class zcl_adash_aunit_no_coverage definition
  public
  final
  create public
  inheriting from cl_aucv_test_runner_abstract.

  public section.
    METHODS: run_for_program_keys REDEFINITION,
             run_for_test_class_handles REDEFINITION.
  protected section.
  private section.
endclass.



class zcl_adash_aunit_no_coverage implementation.

  method run_for_program_keys.
    data:
      program_Name      type progname,
      converted_Key     type cl_Aucv_Task=>ty_Object_Directory_Element,
      converted_Keys    type cl_Aucv_Task=>ty_Object_Directory_Elements.

    check i_Program_Keys is not initial.
    data(listener) = cl_Saunit_Gui_Service=>create_Listener( ).
    data(task) =
      cl_Aucv_Task=>create(
        exporting i_Listener =              listener
                  i_Measure_Coverage =      abap_false
                  i_Max_Risk_Level =        i_Limit_On_Risk_Level
                  i_Max_Duration_Category = i_Limit_On_Duration_Category  ).

    loop at i_Program_Keys assigning field-symbol(<tadir_Key>).
      converted_Key-object =     <tadir_Key>-obj_Type.
      converted_Key-obj_Name =   <tadir_Key>-obj_Name.
      insert converted_Key into table converted_Keys.
    endloop.
    task->add_Associated_Unit_Tests( converted_Keys ).
    task->run( if_Aunit_Task=>c_Run_Mode-catch_Short_Dump ).
    e_Aunit_Result = listener->get_Result_After_End_Of_Task( ).


  endmethod.

  method run_for_test_class_handles.
    data:
      xpt_Caught        type ref to cx_Root,
      program_Name      type syrepid,
      task              type ref to cl_Aucv_Task,
      test_Class_Handle type ref to if_Aunit_Test_Class_Handle,
      converted_Key     type cl_Aucv_Task=>ty_Object_Directory_Element,
      converted_Keys    type cl_Aucv_Task=>ty_Object_Directory_Elements,
      listener          type ref to if_Saunit_Internal_Listener.

    listener = cl_Saunit_gui_Service=>create_Listener( ).
    task = cl_Aucv_Task=>create(
        i_Listener =              listener
        i_Measure_Coverage =      abap_false
        i_Max_Risk_Level =        i_Limit_On_Risk_Level
        i_Max_Duration_Category = i_Limit_On_Duration_Category
        i_Duration_Setting =      i_Custom_Duration   ).

    loop at i_Test_Class_Handles into test_Class_Handle.
      if ( program_Name is initial ).
        program_Name  = test_Class_Handle->get_Program_Name( ).
      endif.
      task->add_Test_Class_Handle( test_Class_Handle ).
    endloop.
    task->run( i_Mode ).
    e_Aunit_Result = listener->get_Result_After_End_Of_Task( ).


  endmethod.

endclass.
