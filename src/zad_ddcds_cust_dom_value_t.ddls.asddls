//@AbapCatalog.sqlViewName: 'DDCDS_CUSTDFVT'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZAD_DDCDS_CUST_DOM_VALUE_T
  with parameters
    p_domain_name : sxco_ad_object_name --abap.char(30)
  as select from dd07t
{
  key domname    as domain_name,
  key valpos     as value_position,
      @Semantics.language: true
  key ddlanguage as language,
      domvalue_l as Value,
      @Semantics.text: true
      ddtext     as Description
}
where
  domname        = $parameters.p_domain_name
  and dd07t.as4local = 'A'
