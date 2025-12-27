CLASS zc_modify_rap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zc_modify_rap IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
**MODIFY ENTITY, ENTITIES, field_spec
**1->...  { FROM fields_tab }
**       CREATE, CREATE BY, UP☺DATE, DELETE, EXECUTE
**       For DELETE, EXECUTE we can use this option only
**       The %control structure must be filled explicitly in the internal table fields_tab for CREATE, CREATE BY and UPDATE
*    TYPES: lty_t_travel_m  TYPE TABLE FOR CREATE zadi_travel_m,
*           lty_t_booking_m TYPE TABLE FOR CREATE zadi_travel_m\_Booking.
*
**   IMPORTANT: EARLY NUMBERING is triggered automatically when an entry being created
***********
***CREATE
***********
*    MODIFY ENTITY zadi_travel_m
*        CREATE FROM VALUE lty_t_travel_m(
*                                            ( %cid   = 'cid1'                           "necessary field: should be populated
*                                              %data-BeginDate  = '30092024'             "field we're adding
*                                              %control-BeginDate = if_abap_behv=>mk-on  "indicator of a changed field
*                                            )
*                                         )
**   Create by association
*        CREATE BY \_Booking FROM VALUE lty_t_booking_m(
*                                                        ( %cid_ref = 'cid1'
*                                                          %target  = VALUE #( ( %cid = 'cid11'
*                                                                                %data-BookingDate = '01102024'
*                                                                                %control-BookingDate = if_abap_behv=>mk-on ) )
*                                                        )
*                                                      )
*
*     FAILED FINAL(lt_failed)        "FINAL it's kind of a DATA inline declaraion, the difference is that when FINAL is used, variable CAN'T be changed.
*     MAPPED FINAL(lt_mapped)
*     REPORTED FINAL(lt_reported).   "
*
*    IF lt_failed IS NOT INITIAL.
*      out->write( lt_failed ).
*    ELSE.
*      COMMIT ENTITIES.              "necessary to save data:
*    ENDIF.

*************************
***DELETE
*********************
    "DELETE Root entity (child will be deleted too)
*    MODIFY ENTITY zadi_travel_m
*        DELETE FROM VALUE #( ( %key-TravelId = '00000026' ) )
*     FAILED FINAL(lt_failed_del)
*     MAPPED FINAL(lt_mapped_del)
*     REPORTED FINAL(lt_reported_del).
*
*    IF lt_failed_del IS NOT INITIAL.
*      out->write( lt_failed_del ).
*    ELSE.
*      COMMIT ENTITIES.              "necessary to save data:
*    ENDIF.
*    "Delete only child entity
*    MODIFY ENTITY zadi_booking_m
*        DELETE FROM VALUE #( ( %key-TravelId  = '00000028'
*                               %key-BookingId = '0010') )
*     FAILED FINAL(lt_failed_del)
*     MAPPED FINAL(lt_mapped_del)
*     REPORTED FINAL(lt_reported_del).
*
*    IF lt_failed_del IS NOT INITIAL.
*      out->write( lt_failed_del ).
*    ELSE.
*      COMMIT ENTITIES.              "necessary to save data:
*    ENDIF.


**| { AUTO FILL CID WITH fields_tab }
**IMPORTANT: with autofill you can't use created by association
*    TYPES: lty_t_travel_m  TYPE TABLE FOR CREATE zadi_travel_m,
*           lty_t_booking_m TYPE TABLE FOR CREATE zadi_travel_m\_Booking.
*    MODIFY ENTITY zadi_travel_m
*        CREATE AUTO FILL CID WITH VALUE lty_t_travel_m(
*                                            (
**                                              "%cid   = 'cid1'                           "NOT needed to be populated
*                                              %data-BeginDate  = '20240930'             "field we're adding
*                                              %control-BeginDate = if_abap_behv=>mk-on  "indicator of a changed field
*                                            )
*                                         )
*     FAILED FINAL(lt_failed)        "FINAL it's kind of a DATA inline declaraion, the difference is that when FINAL is used, variable CAN'T be changed.
*     MAPPED FINAL(lt_mapped)
*     REPORTED FINAL(lt_reported).   "
*
*    IF lt_failed IS NOT INITIAL.
*      out->write( lt_failed ).
*    ELSE.
*      COMMIT ENTITIES.              "necessary to save data:
*    ENDIF.

*->   | { [AUTO FILL CID] FIELDS ( comp1 comp2 ... ) WITH fields_tab }
*    MODIFY ENTITIES OF zadi_travel_m "pay attention that keyword ENTITIES is used, so it's a Long form of a syntax
*        ENTITY zadi_travel_m
*        UPDATE FIELDS ( BeginDate )
*        WITH VALUE #( ( %key-TravelId = '00000030'
*                        %data-BeginDate = '20241001' ) )
*        ENTITY zadi_travel_m
*        DELETE FROM VALUE #( ( TravelId = '00000028' ) ) .
*
*    COMMIT ENTITIES.

*4->  | { [AUTO FILL CID] SET FIELDS WITH fields_tab } ...☺ DO NOT USE THIS as could cause performance issues
*    MODIFY ENTITY zadi_travel_m
*    UPDATE SET FIELDS WITH VALUE #( ( %key-TravelId = '00000030'
*                                      %data-BeginDate = '20241111' ) ).
*    COMMIT ENTITIES.



  ENDMETHOD.

ENDCLASS.
