@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking interface view managed'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZADI_BOOKING_M
  as select from zad_booking_m
  association to parent zadi_travel_m   as _Travel         on  $projection.TravelId = _Travel.TravelId
  composition [0..*] of ZADI_BOOKSUPPL_M as _BookingSuppl 
  association [1..1] to /DMO/I_Carrier         as _Carrier        on  $projection.CarrierId = _Carrier.AirlineID
  association [0..1] to /DMO/I_Customer        as _Customer       on  $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Connection      as _Connection     on  $projection.CarrierId    = _Connection.AirlineID
                                                                  and $projection.ConnectionId = _Connection.ConnectionID
  association [1..*] to ZADI_BOOKING_STATUS_VH as _Booking_Status on  $projection.BookingStatus = _Booking_Status.Value
{
  key travel_id       as TravelId,
  key booking_id      as BookingId,
      booking_date    as BookingDate,
      customer_id     as CustomerId,
      carrier_id      as CarrierId,
      connection_id   as ConnectionId,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,
      //the persistent field last_changed_at plays a special role as a field ETag 
      @Semantics.systemDateTime.localInstanceLastChangedAt: true      
      last_changed_at as LastChangedAt,

      //Association
      _Travel,
      _BookingSuppl,
      _Carrier,
      _Customer,
      _Connection,
      _Booking_Status
}
