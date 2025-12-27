@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Overall status value help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #A,
    sizeCategory: #S,
    dataClass: #CUSTOMIZING
}
define view entity zadi_Overall_Status_vh 
    as select from ZAD_DDCDS_CUST_DOM_VALUE_T( p_domain_name: '/DMO/OVERALL_STATUS' )
{
//    key domain_name,
//    key value_position,
    @Semantics.language: true
    key language,
    @UI.textArrangement: #TEXT_ONLY
    @UI.lineItem: [{ importance: #HIGH }]
//    @ObjectModel.text.association: ''
   key Value,
    @Semantics.text: true
    Description
}
