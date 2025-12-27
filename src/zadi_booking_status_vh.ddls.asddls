@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking status Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #S,
    dataClass: #CUSTOMIZING
}
define view entity ZADI_BOOKING_STATUS_VH
  as select from ZAD_DDCDS_CUST_DOM_VALUE_T( p_domain_name: '/DMO/STATUS' )
{
//  key domain_name,
//  key value_position,
      @Semantics.language: true
  key language,
      @UI.textArrangement: #TEXT_ONLY
      @UI.lineItem: [{ importance: #HIGH }]
      //    @ObjectModel.text.association: ''
  key Value,
      @Semantics.text: true
      Description
}
