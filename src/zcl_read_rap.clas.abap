CLASS zcl_read_rap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_read_rap IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

*>>>    SHORT FORM
*    TYPES: lty_t_zadi_travel_m TYPE TABLE FOR READ IMPORT zadi_travel_m.
*    TYPES: lty_t_zadi_travel_m_assoc TYPE TABLE FOR READ IMPORT zadi_travel_m\_Booking.
*    TYPES: lty_s_zadi_travel_m TYPE STRUCTURE FOR READ IMPORT zadi_travel_m.
*    DATA ls_zadi_travel_m TYPE STRUCTURE FOR READ RESULT zadi_travel_m.

*   FIRST WAY
**    %control - responsible to mark fields which should be displayed
*    READ ENTITY zadi_travel_m
*        FROM VALUE lty_t_zadi_travel_m( ( %key-TravelId = '00000001'
*                                          %control = VALUE #( AgencyId   = if_abap_behv=>mk-on
*                                                              CustomerId = if_abap_behv=>mk-on
*                                                              BeginDate  = if_abap_behv=>mk-on )
*                                      ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).

*   SECOND WAY: USING Fields
*    READ ENTITY zadi_travel_m
*        FIELDS ( AgencyId CustomerId BeginDate )
*        WITH VALUE lty_t_zadi_travel_m( ( %key-TravelId = '00000001' ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).

*   SECOND WAY: USING ALL Fields
*    READ ENTITY zadi_travel_m
*        ALL FIELDS
*        WITH VALUE lty_t_zadi_travel_m( ( %key-TravelId = '00000001' )
*                                        ( %key-TravelId = '00000016' )
*                    )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).

*   SECOND WAY: USING association
*    READ ENTITY zadi_travel_m
*        BY \_Booking
*        ALL FIELDS
*        WITH VALUE lty_t_zadi_travel_m_assoc( ( %key-TravelId = '00000001' ) )
*    RESULT DATA(lt_result_short)
*    FAILED DATA(lt_failed_short).
*    IF lt_failed_short IS NOT INITIAL.
*      out->write('Read failed'  ).
*    ELSE.
*      out->write( lt_result_short ).
*    ENDIF.
*<<<    SHORT FORM

*>>>    LONG FORM
*    TYPES: lty_t_zadi_travel_m  TYPE TABLE FOR READ IMPORT zadi_travel_m.
*    TYPES: lty_t_zadi_booking_m TYPE TABLE FOR READ IMPORT zadi_booking_m.
*    READ ENTITIES OF zadi_travel_m
*        ENTITY zadi_travel_m
*        ALL FIELDS
*        WITH VALUE lty_t_zadi_travel_m( ( %key-TravelId = '00000001' ) )
*    RESULT DATA(lt_result_travel)
*        ENTITY zadi_booking_m
*        ALL FIELDS
*        "You need to provide full key!!!
*        WITH VALUE lty_t_zadi_booking_m( ( %key-TravelId = '00000001' %key-BookingId = '0001') )
*    RESULT DATA(lt_result_booking)
*    FAILED DATA(lt_failed_long).
*
*    IF lt_failed_long IS NOT INITIAL.
*      out->write('Read failed'  ).
*    ELSE.
*      out->write( lt_result_travel ).
*      out->write( lt_result_booking ).
*    ENDIF.
*<<<    LONG FORM

*>>>    DYNAMIC FORM
*"Read one entity
*    DATA: lt_optab      TYPE abp_behv_retrievals_tab,
*          lt_travel     TYPE TABLE FOR READ IMPORT zadi_travel_m,
*          lt_travel_res TYPE TABLE FOR READ RESULT zadi_travel_m.
*
*    lt_travel = VALUE #( ( %key-TravelId = '00000001'
*                           %control = VALUE #( AgencyId   = if_abap_behv=>mk-on
*                                               CustomerId = if_abap_behv=>mk-on
*                                               BeginDate  = if_abap_behv=>mk-on )
*                       ) ).
*    "Entity name in CAPITAL
*    lt_optab = VALUE #( ( op          = if_abap_behv=>op-r-read
*                          entity_name  = 'ZADI_TRAVEL_M'
*                          instances   = REF #( lt_travel )
*                          results     = REF #( lt_travel_res ) )
*
*                      ).
*
*    READ ENTITIES OPERATIONS lt_optab
*        FAILED DATA(lt_failed_dyn).
*    IF lt_failed_dyn IS NOT INITIAL.
*      out->write('Read failed'  ).
*    ELSE.
*      out->write( lt_travel_res ).
*    ENDIF.
*
*"Read multiple entitys (use association)
*    DATA: lt_optab       TYPE abp_behv_retrievals_tab,
*          lt_travel      TYPE TABLE FOR READ IMPORT zadi_travel_m,
*          lt_travel_res  TYPE TABLE FOR READ RESULT zadi_travel_m,
*          lt_booking     TYPE TABLE FOR READ IMPORT zadi_travel_m\_Booking,
*          lt_booking_res TYPE TABLE FOR READ RESULT zadi_travel_m\_Booking.
*
*    lt_travel = VALUE #( ( %key-TravelId = '00000001'
*                           %control = VALUE #( AgencyId   = if_abap_behv=>mk-on
*                                               CustomerId = if_abap_behv=>mk-on
*                                               BeginDate  = if_abap_behv=>mk-on ) )
*                       ).
*
*    lt_booking = VALUE #( ( %key-TravelId = '00000001'
*                           %control = VALUE #( BookingId     = if_abap_behv=>mk-on
*                                               BookingStatus = if_abap_behv=>mk-on
*                                               BookingDate   = if_abap_behv=>mk-on ) )
*                       ).
*
*    "Entity name in CAPITAL
*    lt_optab = VALUE #( ( op          = if_abap_behv=>op-r-read
*                          entity_name  = 'ZADI_TRAVEL_M'
*                          instances   = REF #( lt_travel )
*                          results     = REF #( lt_travel_res ) )
*                        ( op          = if_abap_behv=>op-r-read_ba
*                          entity_name  = 'ZADI_TRAVEL_M'
*                          sub_name     = '_BOOKING'
*                          instances   = REF #( lt_booking )
*                          results     = REF #( lt_booking_res ) )
*
*                      ).
*
*    READ ENTITIES OPERATIONS lt_optab
*        FAILED DATA(lt_failed_dyn).
*    IF lt_failed_dyn IS NOT INITIAL.
*      out->write('Read failed'  ).
*    ELSE.
*      out->write( lt_travel_res ).
*      out->write( lt_booking_res ).
*    ENDIF.
*
**<<<    DYNAMIC FORM

*  cl_demo_output=>display(
*  REDUCE i( INIT s = 0
*            FOR  i = 1 UNTIL i > 10
*            NEXT s = s + i ) ).

    DATA(lv_val) =   REDUCE i( INIT s = 0
                     FOR  i = 1 UNTIL i > 10
                     NEXT s = s + i ).

    DATA: lv_val1 TYPE i,
          lv_cnt       TYPE i VALUE 1.

    DO lv_cnt TIMES.
      IF lv_cnt > 10.
        EXIT.
      ENDIF.
      lv_cnt = lv_cnt + 1.
      lv_val1 = lv_val1 + lv_cnt.
    ENDDO.

    out->write( lv_val1 ).

  ENDMETHOD.


ENDCLASS.
