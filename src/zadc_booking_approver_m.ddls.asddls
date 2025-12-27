@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Approver Projection Booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZADC_BOOKING_APPROVER_M
  as projection on ZADI_BOOKING_M
{
  key TravelId,
  key BookingId,
      BookingDate,
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName          as CustomerName,
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _Carrier.Name               as CarrierName,
      ConnectionId,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      @ObjectModel.text.element: [ 'BookingStatusText' ]
      BookingStatus,
      _Booking_Status.Description as BookingStatusText : localized,
      LastChangedAt,
      /* Associations */
      _BookingSuppl,
      _Booking_Status,
      _Carrier,
      _Connection,
      _Customer,
      _Travel : redirected to parent ZADC_TRAVEL_APPROVER_M
}
