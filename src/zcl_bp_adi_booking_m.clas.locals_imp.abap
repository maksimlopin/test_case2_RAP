CLASS lhc_zadi_booking_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zadi_booking_m\_Bookingsuppl.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zadi_booking_m RESULT result.
    METHODS validateconnection FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_booking_m~validateconnection.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_booking_m~validatecurrencycode.

    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_booking_m~validatecustomer.

    METHODS validateflightprice FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_booking_m~validateflightprice.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_booking_m~validatestatus.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zadi_booking_m~calculatetotalprice.

ENDCLASS.

CLASS lhc_zadi_booking_m IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    DATA: lv_max_booking_suppl_id TYPE /dmo/booking_supplement_id .

    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
      ENTITY zadi_booking_m  BY \_BookingSuppl
        FROM CORRESPONDING #( entities )
        LINK DATA(lt_booking_supplements).

*    " Loop over all unique tky (TravelID + BookingID)
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_booking_group>) GROUP BY <ls_booking_group>-%tky.

      " Get highest bookingsupplement_id from bookings belonging to booking
      lv_max_booking_suppl_id = REDUCE #( INIT max = CONV /dmo/booking_supplement_id( '0' )
                                          FOR  ls_booksuppl IN lt_booking_supplements USING KEY entity
                                                                             WHERE (     source-TravelId  = <ls_booking_group>-TravelId
                                                                                     AND source-BookingId = <ls_booking_group>-BookingId )
                                           NEXT max = COND /dmo/booking_supplement_id( WHEN   ls_booksuppl-target-BookingSupplementId > max
                                                                          THEN ls_booksuppl-target-BookingSupplementId
                                                                          ELSE max )
                                     ).
      " Get highest assigned bookingsupplement_id from incoming entities
      lv_max_booking_suppl_id = REDUCE #( INIT max = lv_max_booking_suppl_id
                                       FOR  entity IN entities USING KEY entity
                                                               WHERE (     TravelId  = <ls_booking_group>-TravelId
                                                                       AND BookingId = <ls_booking_group>-BookingId )
                                       FOR  target IN entity-%target
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   target-BookingSupplementId > max
                                                                                     THEN target-BookingSupplementId
                                                                                     ELSE max )
                                     ).


      " Loop over all entries in entities with the same TravelID and BookingID
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity WHERE TravelId  = <ls_booking_group>-TravelId
                                                                            AND BookingId = <ls_booking_group>-BookingId.

        " Assign new booking_supplement-ids
        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booksuppl_wo_numbers>).
          APPEND CORRESPONDING #( <ls_booksuppl_wo_numbers> ) TO mapped-zadi_booksuppl_m ASSIGNING FIELD-SYMBOL(<ls_mapped_booksuppl>).
          IF <ls_booksuppl_wo_numbers>-BookingSupplementId IS INITIAL.
            lv_max_booking_suppl_id += 1 .
            <ls_mapped_booksuppl>-BookingSupplementId = lv_max_booking_suppl_id.
          ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.


  ENDMETHOD.

  METHOD get_instance_features.


    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
      ENTITY zadi_travel_m BY \_Booking
      FIELDS ( TravelId BookingId BookingStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_booking).

    result = VALUE #( FOR ls_booking IN lt_booking
                        ( %tky = ls_booking-%tky
                          %features-%assoc-_BookingSuppl      = COND #( WHEN ls_booking-BookingStatus = 'X'
                                                                        THEN if_abap_behv=>fc-o-disabled
                                                                        ELSE if_abap_behv=>fc-o-enabled )
                         )
                      ).

  ENDMETHOD.

  METHOD validateConnection.
  ENDMETHOD.

  METHOD validateCurrencyCode.
  ENDMETHOD.

  METHOD validateCustomer.
  ENDMETHOD.

  METHOD validateFlightPrice.
  ENDMETHOD.

  METHOD validateStatus.
  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA: lt_travel TYPE STANDARD TABLE OF zadi_travel_m WITH UNIQUE SORTED KEY key COMPONENTS TravelId.

    lt_travel = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).

    MODIFY ENTITIES OF zadi_travel_m IN LOCAL MODE
    ENTITY zadi_travel_m
    EXECUTE recalcTotPrice
    FROM CORRESPONDING #( lt_travel ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
