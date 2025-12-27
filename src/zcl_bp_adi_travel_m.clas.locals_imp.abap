CLASS lhc_zadi_travel_m DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys
                  REQUEST requested_authorizations
                  FOR zadi_travel_m
      RESULT    result.
    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zadi_travel_m~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zadi_travel_m~copytravel.

    METHODS recalctotprice FOR MODIFY
      IMPORTING keys FOR ACTION zadi_travel_m~recalctotprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zadi_travel_m~rejecttravel RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zadi_travel_m RESULT result.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_travel_m~validatecustomer.
    METHODS validatebookingfee FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_travel_m~validatebookingfee.

    METHODS validatecurrencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_travel_m~validatecurrencycode.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_travel_m~validatedates.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zadi_travel_m~validatestatus.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zadi_travel_m~calculatetotalprice.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zadi_travel_m\_booking.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities
                  FOR CREATE zadi_travel_m.

ENDCLASS.

CLASS lhc_zadi_travel_m IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.

    TYPES: lty_s_zadi_travel_m_mpd TYPE STRUCTURE FOR MAPPED   EARLY zadi_travel_m,
           lty_s_zadi_travel_m_fld TYPE STRUCTURE FOR FAILED   EARLY zadi_travel_m,
           lty_s_zadi_travel_m_rep TYPE STRUCTURE FOR REPORTED EARLY zadi_travel_m,
           lty_t_entities          TYPE TABLE FOR CREATE zadi_travel_m.

    DATA: lt_entities TYPE lty_t_entities,
          ls_entities LIKE LINE OF lt_entities,
          lt_travel_m TYPE TABLE FOR MAPPED EARLY zadi_travel_m,
          ls_travel_m LIKE LINE OF lt_travel_m.

    lt_entities = entities.

    DELETE lt_entities WHERE TravelId IS NOT INITIAL.

    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = 'ZAD_TRV_M'
            quantity          = CONV #( lines(  lt_entities ) )
          IMPORTING
            number            = DATA(lv_latest_num)
            returncode        = DATA(lv_code)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found.
      CATCH cx_number_ranges INTO DATA(lx_err).
        LOOP AT lt_entities INTO ls_entities.
          APPEND  VALUE lty_s_zadi_travel_m_fld( %cid  = ls_entities-%cid
                                                 %key  = ls_entities-%key ) TO failed-zadi_travel_m.
          APPEND  VALUE lty_s_zadi_travel_m_rep( %cid  = ls_entities-%cid
                                                 %key  = ls_entities-%key
                                                 %msg = lx_err ) TO reported-zadi_travel_m.
        ENDLOOP.
        EXIT.
    ENDTRY.

    ASSERT lv_qty = lines(  lt_entities ).

    DATA(lv_curr_num) = lv_latest_num - lv_qty.
    LOOP AT lt_entities INTO ls_entities.
      lv_curr_num += lv_curr_num. " + 1
      APPEND  VALUE lty_s_zadi_travel_m_mpd( %cid     = ls_entities-%cid
                                             TravelId = lv_curr_num ) TO mapped-zadi_travel_m.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    DATA: lv_max_booking TYPE /dmo/booking_id.

    "Read
    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
    ENTITY zadi_travel_m BY \_Booking
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_group_entity>)
        GROUP BY <ls_group_entity>-TravelId.
      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                                   FOR ls_link IN lt_link_data USING KEY entity
                                      WHERE ( source-TravelId = <ls_group_entity>-TravelId )
                                   NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
                                                                       THEN ls_link-target-BookingId
                                                                       ELSE lv_max )
                               ).

      lv_max_booking = REDUCE #( INIT lv_max = lv_max_booking
                                  FOR ls_entity IN entities USING KEY entity
                                        WHERE ( TravelId = <ls_group_entity>-TravelId )
                                    FOR ls_booking IN ls_entity-%target
                                    NEXT lv_max =  COND /dmo/booking_id( WHEN lv_max < ls_booking-BookingId
                                                                         THEN ls_booking-BookingId
                                                                         ELSE lv_max )

                              ).


      LOOP AT entities ASSIGNING FIELD-SYMBOL(<ls_entities>)
        USING KEY entity WHERE TravelId = <ls_group_entity>-TravelId.

        LOOP AT <ls_entities>-%target ASSIGNING FIELD-SYMBOL(<ls_booking>).
          APPEND CORRESPONDING #( <ls_booking> ) TO mapped-zadi_booking_m ASSIGNING FIELD-SYMBOL(<ls_new_map_book>).
          IF <ls_booking>-BookingId IS INITIAL.
            lv_max_booking = lv_max_booking + 10.
            <ls_new_map_book>-BookingId = lv_max_booking.
          ENDIF.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

  METHOD acceptTravel.

    TYPES: lty_zadi_travel_m TYPE TABLE FOR UPDATE zadi_travel_m,
           lty_result        TYPE TABLE FOR ACTION RESULT zadi_travel_m~accepttravel.

    MODIFY ENTITIES OF zadi_travel_m IN LOCAL MODE
        ENTITY zadi_travel_m
            UPDATE FIELDS ( OverallStatus )
            WITH VALUE lty_zadi_travel_m( FOR ls_keys IN keys ( %tky                = ls_keys-%tky
                                                                %data-OverallStatus = 'A' ) ). "FOR loop is used to loop through all keys of importing KEYS table


    "check if update applied
    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
    ENTITY zadi_travel_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE lty_result( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                            %param = ls_result ) ).

  ENDMETHOD.

  METHOD rejectTravel.


    TYPES: lty_zadi_travel_m TYPE TABLE FOR UPDATE zadi_travel_m,
           lty_result        TYPE TABLE FOR ACTION RESULT zadi_travel_m~rejecttravel.

    MODIFY ENTITIES OF zadi_travel_m IN LOCAL MODE
        ENTITY zadi_travel_m
            UPDATE FIELDS ( OverallStatus )
            WITH VALUE lty_zadi_travel_m( FOR ls_keys IN keys ( %tky                = ls_keys-%tky
                                                                %data-OverallStatus = 'X' ) ). "FOR loop is used to loop through all keys of importing KEYS table


    "check if update applied
    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
    ENTITY zadi_travel_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE lty_result( FOR ls_result IN lt_result ( %tky   = ls_result-%tky
                                                            %param = ls_result ) ).

  ENDMETHOD.

  METHOD copyTravel.

    DATA: lt_travel        TYPE TABLE FOR CREATE zadi_travel_m,
          lt_booking_cba   TYPE TABLE FOR CREATE zadi_travel_m\_Booking,
          lt_booksuppl_cba TYPE TABLE FOR CREATE zadi_booking_m\_BookingSuppl.

    "sanity check
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_without_cid>) WITH KEY %cid = ' '.
    ASSERT <ls_without_cid> IS NOT ASSIGNED.

    "read existing data
    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
      ENTITY zadi_travel_m
      ALL FIELDS WITH CORRESPONDING #( keys ) "here we're reading entities which were provided as impornting parameters
      RESULT DATA(lt_travel_r)
      FAILED DATA(lt_failed).

    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
      ENTITY zadi_travel_m BY \_Booking
      ALL FIELDS WITH CORRESPONDING #( lt_travel_r )
      RESULT DATA(lt_booking_r).

    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
      ENTITY zadi_booking_m BY \_BookingSuppl
      ALL FIELDS WITH CORRESPONDING #( lt_booking_r )
      RESULT DATA(lt_booksuppl_r).

    LOOP AT lt_travel_r ASSIGNING FIELD-SYMBOL(<ls_travel_r>).

      "first way of append
*      APPEND INITIAL LINE TO lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
*      <ls_travel>-%cid = keys[ KEY entity TravelId = <ls_travel_r>-TravelId ]-%cid.
*      <ls_travel>-%data = CORRESPONDING #( <ls_travel_r> EXCEPT TravelId ).
      "Second way to append
      APPEND VALUE #( %cid = keys[ KEY entity TravelId = <ls_travel_r>-TravelId ]-%cid
                      %data = CORRESPONDING #( <ls_travel_r> EXCEPT TravelId ) )
                      TO lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
      <ls_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
      <ls_travel>-OverallStatus = 'O'.

      APPEND VALUE #( %cid_ref = <ls_travel>-%cid )
        TO lt_booking_cba ASSIGNING FIELD-SYMBOL(<ls_booking>).


      LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<ls_booking_r>)
        USING KEY entity
        WHERE TravelId = <ls_travel_r>-TravelId.

        APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId
                        %data = CORRESPONDING #( <ls_booking_r> EXCEPT TravelId ) )
                        TO <ls_booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_new>).
        <ls_booking_new>-BookingStatus = 'N'.


        APPEND VALUE #( %cid_ref = <ls_booking_new>-%cid )
            TO lt_booksuppl_cba ASSIGNING FIELD-SYMBOL(<ls_booksupp>).

        LOOP AT lt_booksuppl_r ASSIGNING FIELD-SYMBOL(<ls_booksupp_r>)
            USING KEY entity
            WHERE TravelId = <ls_travel_r>-TravelId AND BookingId = <ls_booking_r>-BookingId.

          APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId && <ls_booksupp_r>-BookingSupplementId
                          %data = CORRESPONDING #( <ls_booksupp_r> EXCEPT TravelId BookingId ) )
                          TO <ls_booksupp>-%target.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zadi_travel_m IN LOCAL MODE
        ENTITY zadi_travel_m
        CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
        WITH lt_travel
        ENTITY zadi_travel_m
        CREATE BY \_Booking
        FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
        WITH lt_booking_cba
        ENTITY zadi_booking_m
        CREATE BY \_BookingSuppl
        FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
        WITH lt_booksuppl_cba
        MAPPED DATA(lt_mapped).

    mapped-zadi_travel_m = lt_mapped-zadi_travel_m.



  ENDMETHOD.

  METHOD recalcTotPrice.

    TYPES: BEGIN OF ty_s_total,
             price TYPE /dmo/total_price,
             curr  TYPE /dmo/currency_code,
           END OF ty_s_total.
    DATA: lt_total      TYPE TABLE OF ty_s_total,
          lv_conv_price TYPE ty_s_total-price..

    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
      ENTITY zadi_travel_m
      FIELDS ( BookingFee CurrencyCode )
      WITH CORRESPONDING #( keys )
      RESULT DATA(Lt_travel).

    DELETE lt_travel WHERE CurrencyCode IS INITIAL.

    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
    ENTITY zadi_travel_m BY \_Booking
    FIELDS ( FlightPrice CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Lt_ba_booking).

    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
    ENTITY zadi_booking_m BY \_BookingSuppl
    FIELDS ( Price CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(Lt_ba_booksuppl).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      lt_total =  VALUE #( ( price = <ls_travel>-BookingFee curr = <ls_travel>-CurrencyCode ) ).

      LOOP AT lt_ba_booking ASSIGNING FIELD-SYMBOL(<ls_booking>)
                                 USING KEY entity
                                  WHERE TravelId = <ls_travel>-TravelId
                                  AND CurrencyCode IS NOT INITIAL.

        APPEND VALUE #( price = <ls_booking>-FlightPrice curr = <ls_booking>-CurrencyCode )
           TO lt_total.

        LOOP AT lt_ba_booksuppl ASSIGNING FIELD-SYMBOL(<ls_booksuppl>)
                                          USING KEY entity
                                          WHERE TravelId = <ls_booking>-TravelId
                                           AND  BookingId = <ls_booking>-BookingId
                                           AND CurrencyCode IS NOT INITIAL..
          APPEND VALUE #( price = <ls_booksuppl>-Price curr = <ls_booksuppl>-CurrencyCode )
           TO lt_total.
        ENDLOOP.

      ENDLOOP.

      LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<ls_total>).

        IF <ls_total>-curr = <ls_travel>-CurrencyCode.
          lv_conv_price = <ls_total>-price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <ls_total>-price
              iv_currency_code_source = <ls_total>-curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   =  cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = lv_conv_price
          ).

        ENDIF.

        <ls_travel>-TotalPrice =  <ls_travel>-TotalPrice + lv_conv_price.
      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF zadi_travel_m IN LOCAL MODE
     ENTITY zadi_travel_m
     UPDATE FIELDS ( TotalPrice )
     WITH CORRESPONDING #( lt_travel ).


  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
        ENTITY zadi_travel_m
        FIELDS ( TravelId OverallStatus )
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
                        ( %tky = ls_travel-%tky
                          %features-%action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                                   THEN if_abap_behv=>fc-o-disabled
                                                                   ELSE if_abap_behv=>fc-o-enabled )
                          %features-%action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                   THEN if_abap_behv=>fc-o-disabled
                                                                   ELSE if_abap_behv=>fc-o-enabled )
                          %features-%assoc-_Booking      = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                   THEN if_abap_behv=>fc-o-disabled
                                                                   ELSE if_abap_behv=>fc-o-enabled )
                         )
                      ).


  ENDMETHOD.

  METHOD validateCustomer.

    TYPES: lty_s_failed   TYPE STRUCTURE FOR FAILED LATE zadi_travel_m,
           lty_s_reported TYPE STRUCTURE FOR REPORTED LATE zadi_travel_m.

    READ ENTITY IN LOCAL MODE zadi_travel_m
      FIELDS ( CustomerId )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_travel).

    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).
    DELETE lt_cust WHERE customer_id IS INITIAL.


    IF lt_cust IS NOT INITIAL.

      SELECT
      FROM /dmo/customer
      FIELDS customer_id
      FOR ALL ENTRIES IN @lt_cust
      WHERE customer_id = @lt_cust-customer_id
      INTO TABLE @DATA(lt_cust_db).
      IF sy-subrc <> 0.

        LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
          IF <ls_travel>-CustomerId IS INITIAL
          OR NOT line_exists(  lt_cust_db[ customer_id = <ls_travel>-CustomerId ] ).

            APPEND VALUE #( %tky = <ls_travel>-%tky )
              TO failed-zadi_travel_m.

            APPEND VALUE #( %tky = <ls_travel>-%tky
                                         %msg = NEW zcx_flight_legacy( textid      = /dmo/cx_flight_legacy=>customer_unkown
                                                                       customer_id = <ls_travel>-CustomerId
                                                                       severity    = if_abap_behv_message=>severity-error )
                                         %element-customerid = if_abap_behv=>mk-on
                                       )
              TO reported-zadi_travel_m.

          ENDIF.

        ENDLOOP.

      ENDIF.

    ENDIF.

  ENDMETHOD.

  METHOD validateBookingFee.

  ENDMETHOD.

  METHOD validateCurrencyCode.

  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF zadi_travel_m IN LOCAL MODE
            ENTITY zadi_travel_m
              FIELDS ( BeginDate EndDate )
              WITH CORRESPONDING #( keys )
            RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(ls_travel).

      IF ls_travel-EndDate < ls_travel-BeginDate.  "end_date before begin_date

        APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-zadi_travel_m.

        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW zcx_flight_legacy(
                                                      textid                = zcx_flight_legacy=>begin_date_before_system_date
                                                      travel_id             = ls_travel-TravelId
                                                      begin_date            = ls_travel-BeginDate
                                                      end_date              = ls_travel-EndDate
                                                      severity              = if_abap_behv_message=>severity-error
                                                    )
                        %element-BeginDate   = if_abap_behv=>mk-on
                        %element-EndDate     = if_abap_behv=>mk-on
                     ) TO reported-zadi_travel_m.

      ELSEIF ls_travel-BeginDate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future

        APPEND VALUE #( %tky        = ls_travel-%tky ) TO failed-zadi_travel_m.

        APPEND VALUE #( %tky = ls_travel-%tky
                        %msg = NEW zcx_flight_legacy(
                                    textid   = zcx_flight_legacy=>begin_date_before_system_date
                                    severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate  = if_abap_behv=>mk-on
                        %element-EndDate    = if_abap_behv=>mk-on
                      ) TO reported-zadi_travel_m.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.

*    READ ENTITIES OF yi_travel_tech_m IN LOCAL MODE
*        ENTITY yi_travel_tech_m
*          FIELDS ( OverallStatus )
*          WITH CORRESPONDING #( keys )
*        RESULT DATA(lt_travels).
*
*    LOOP AT lt_travels INTO DATA(ls_travel).
*      CASE ls_travel-OverallStatus.
*        WHEN 'O'.  " Open
*        WHEN 'X'.  " Cancelled
*        WHEN 'A'.  " Accepted
*
*        WHEN OTHERS.
*          APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-yi_travel_tech_m.
*
*          APPEND VALUE #( %tky = ls_travel-%tky
*                          %msg = NEW /dmo/cm_flight_messages(
*                                     textid = /dmo/cm_flight_messages=>status_invalid
*                                     severity = if_abap_behv_message=>severity-error
*                                     status = ls_travel-OverallStatus )
*                          %element-OverallStatus = if_abap_behv=>mk-on
*                        ) TO reported-yi_travel_tech_m.
*      ENDCASE.
*    ENDLOOP.

  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zadi_travel_m IN LOCAL MODE
      ENTITY zadi_travel_m
      EXECUTE recalcTotPrice
      FROM CORRESPONDING #( keys ).


  ENDMETHOD.

ENDCLASS.
