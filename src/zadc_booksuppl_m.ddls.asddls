@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement Consumption View'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZADC_BOOKSUPPL_M
  as projection on ZADI_BOOKSUPPL_M
{
  key TravelId,
  key BookingId,
  key BookingSupplementId,
      @ObjectModel.text.element: [ 'SupplementDesc' ]
      SupplementId,
       _SupplementText.Description as  SupplementDesc : localized,
      @Semantics.amount.currencyCode : 'CurrencyCode'
      Price,
      CurrencyCode,
      LastChangedAt,
      /* Associations */
      _Booking: redirected to parent ZADC_BOOKING_M,
      _Supplement,
      _SupplementText,
      _Travel: redirected to ZADC_TRAVEL_M
}
