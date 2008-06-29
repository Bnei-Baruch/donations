require File.dirname(__FILE__) + '/../../test_helper'

class PaypalExpressTest < Test::Unit::TestCase
  def setup
    @gateway = PaypalExpressGateway.new(
                :login => 'cody', 
                :password => 'test',
                :pem => ''
               )

    @address = { :address1 => '1234 My Street',
                 :address2 => 'Apt 1',
                 :company => 'Widgets Inc',
                 :city => 'Ottawa',
                 :state => 'ON',
                 :zip => 'K1C2N6',
                 :country => 'Canada',
                 :phone => '(555)555-5555'
               }

    Base.gateway_mode = :test
  end 
  
  def teardown
    Base.gateway_mode = :test
  end 

  def test_live_redirect_url
    Base.gateway_mode = :production
    assert_equal 'https://www.paypal.com/cgibin/webscr?cmd=_express-checkout&token=1234567890', @gateway.redirect_url_for('1234567890')
  end
  
  def test_test_redirect_url
    assert_equal 'https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=1234567890', @gateway.redirect_url_for('1234567890')
  end
  
  def test_get_express_details
    @gateway.expects(:ssl_post).returns(successful_details_response)
    response = @gateway.details_for('EC-2OPN7UJGFWK9OYFV')
  
    assert_instance_of PaypalExpressResponse, response
    assert response.success?
    assert response.test?
    
    assert_equal 'EC-6WS104951Y388951L', response.token
    assert_equal 'FWRVKNRRZ3WUC', response.payer_id
    assert_equal 'buyer@jadedpallet.com', response.email
    
    assert address = response.address
    assert_equal 'Fred Brooks', address['name']
    assert_nil address['company']
    assert_equal '1234 Penny Lane', address['address1']
    assert_nil address['address2']
    assert_equal 'Jonsetown', address['city']
    assert_equal 'NC', address['state']
    assert_equal '23456', address['zip']
    assert_equal 'US', address['country']
    assert_nil address['phone']
  end
  
  def test_authorization
    @gateway.expects(:ssl_post).returns(successful_authorization_response)
    response = @gateway.authorize(300, :token => 'EC-6WS104951Y388951L', :payer_id => 'FWRVKNRRZ3WUC')
    assert response.success?
    assert_not_nil response.authorization
    assert response.test?
  end
  
  def test_default_payflow_currency
    assert_equal 'USD', PayflowExpressGateway.default_currency
  end
  
  def test_default_partner
    assert_equal 'PayPal', PayflowExpressGateway.partner
  end
  
  def test_uk_partner
    assert_equal 'PayPalUk', PayflowExpressUkGateway.partner
  end
  
  def test_handle_non_zero_amount
    xml = REXML::Document.new(@gateway.send(:build_setup_request, 'SetExpressCheckout', 50, {}))
    
    assert_equal '0.50', REXML::XPath.first(xml, '//n2:OrderTotal').text
  end
  
  def test_handles_zero_amount
    xml = REXML::Document.new(@gateway.send(:build_setup_request, 'SetExpressCheckout', 0, {}))
    
    assert_equal '1.00', REXML::XPath.first(xml, '//n2:OrderTotal').text
  end
  
  def test_supported_countries
    assert_equal ['US'], PaypalExpressGateway.supported_countries
  end
  
  def test_button_source
    PaypalExpressGateway.application_id = 'ActiveMerchant_EC'
    
    xml = REXML::Document.new(@gateway.send(:build_sale_or_authorization_request, 'Test', 100, {}))
    assert_equal 'ActiveMerchant_EC', REXML::XPath.first(xml, '//n2:ButtonSource').text
  end
  
  def successful_details_response
    <<-RESPONSE
<?xml version='1.0' encoding='UTF-8'?>
<SOAP-ENV:Envelope xmlns:cc='urn:ebay:apis:CoreComponentTypes' xmlns:sizeship='urn:ebay:api:PayPalAPI/sizeship.xsd' xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:SOAP-ENC='http://schemas.xmlsoap.org/soap/encoding/' xmlns:saml='urn:oasis:names:tc:SAML:1.0:assertion' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:wsu='http://schemas.xmlsoap.org/ws/2002/07/utility' xmlns:ebl='urn:ebay:apis:eBLBaseComponents' xmlns:ds='http://www.w3.org/2000/09/xmldsig#' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:ns='urn:ebay:api:PayPalAPI' xmlns:market='urn:ebay:apis:Market' xmlns:ship='urn:ebay:apis:ship' xmlns:auction='urn:ebay:apis:Auction' xmlns:wsse='http://schemas.xmlsoap.org/ws/2002/12/secext' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>
  <SOAP-ENV:Header>
    <Security xsi:type='wsse:SecurityType' xmlns='http://schemas.xmlsoap.org/ws/2002/12/secext'/>
    <RequesterCredentials xsi:type='ebl:CustomSecurityHeaderType' xmlns='urn:ebay:api:PayPalAPI'>
      <Credentials xsi:type='ebl:UserIdPasswordType' xmlns='urn:ebay:apis:eBLBaseComponents'>
        <Username xsi:type='xs:string'/>
        <Password xsi:type='xs:string'/>
        <Subject xsi:type='xs:string'/>
      </Credentials>
    </RequesterCredentials>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body id='_0'>
    <GetExpressCheckoutDetailsResponse xmlns='urn:ebay:api:PayPalAPI'>
      <Timestamp xmlns='urn:ebay:apis:eBLBaseComponents'>2007-02-12T23:59:43Z</Timestamp>
      <Ack xmlns='urn:ebay:apis:eBLBaseComponents'>Success</Ack>
      <CorrelationID xmlns='urn:ebay:apis:eBLBaseComponents'>c73044f11da65</CorrelationID>
      <Version xmlns='urn:ebay:apis:eBLBaseComponents'>2.000000</Version>
      <Build xmlns='urn:ebay:apis:eBLBaseComponents'>1.0006</Build>
      <GetExpressCheckoutDetailsResponseDetails xsi:type='ebl:GetExpressCheckoutDetailsResponseDetailsType' xmlns='urn:ebay:apis:eBLBaseComponents'>
        <Token xsi:type='ebl:ExpressCheckoutTokenType'>EC-6WS104951Y388951L</Token>
        <PayerInfo xsi:type='ebl:PayerInfoType'>
          <Payer xsi:type='ebl:EmailAddressType'>buyer@jadedpallet.com</Payer>
          <PayerID xsi:type='ebl:UserIDType'>FWRVKNRRZ3WUC</PayerID>
          <PayerStatus xsi:type='ebl:PayPalUserStatusCodeType'>verified</PayerStatus>
          <PayerName xsi:type='ebl:PersonNameType'>
            <Salutation xmlns='urn:ebay:apis:eBLBaseComponents'/>
            <FirstName xmlns='urn:ebay:apis:eBLBaseComponents'>Fred</FirstName>
            <MiddleName xmlns='urn:ebay:apis:eBLBaseComponents'/>
            <LastName xmlns='urn:ebay:apis:eBLBaseComponents'>Brooks</LastName>
            <Suffix xmlns='urn:ebay:apis:eBLBaseComponents'/>
          </PayerName>
          <PayerCountry xsi:type='ebl:CountryCodeType'>US</PayerCountry>
          <PayerBusiness xsi:type='xs:string'/>
          <Address xsi:type='ebl:AddressType'>
            <Name xsi:type='xs:string'>Fred Brooks</Name>
            <Street1 xsi:type='xs:string'>1234 Penny Lane</Street1>
            <Street2 xsi:type='xs:string'/>
            <CityName xsi:type='xs:string'>Jonsetown</CityName>
            <StateOrProvince xsi:type='xs:string'>NC</StateOrProvince>
            <Country xsi:type='ebl:CountryCodeType'>US</Country>
            <CountryName>United States</CountryName>
            <PostalCode xsi:type='xs:string'>23456</PostalCode>
            <AddressOwner xsi:type='ebl:AddressOwnerCodeType'>PayPal</AddressOwner>
            <AddressStatus xsi:type='ebl:AddressStatusCodeType'>Confirmed</AddressStatus>
          </Address>
        </PayerInfo>
        <InvoiceID xsi:type='xs:string'>1230123</InvoiceID>
      </GetExpressCheckoutDetailsResponseDetails>
    </GetExpressCheckoutDetailsResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>    
    RESPONSE
  end
  
  def successful_authorization_response
    <<-RESPONSE
<?xml version='1.0' encoding='UTF-8'?>
<SOAP-ENV:Envelope xmlns:cc='urn:ebay:apis:CoreComponentTypes' xmlns:sizeship='urn:ebay:api:PayPalAPI/sizeship.xsd' xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:SOAP-ENC='http://schemas.xmlsoap.org/soap/encoding/' xmlns:saml='urn:oasis:names:tc:SAML:1.0:assertion' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:wsu='http://schemas.xmlsoap.org/ws/2002/07/utility' xmlns:ebl='urn:ebay:apis:eBLBaseComponents' xmlns:ds='http://www.w3.org/2000/09/xmldsig#' xmlns:xs='http://www.w3.org/2001/XMLSchema' xmlns:ns='urn:ebay:api:PayPalAPI' xmlns:market='urn:ebay:apis:Market' xmlns:ship='urn:ebay:apis:ship' xmlns:auction='urn:ebay:apis:Auction' xmlns:wsse='http://schemas.xmlsoap.org/ws/2002/12/secext' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>
  <SOAP-ENV:Header>
    <Security xsi:type='wsse:SecurityType' xmlns='http://schemas.xmlsoap.org/ws/2002/12/secext'/>
    <RequesterCredentials xsi:type='ebl:CustomSecurityHeaderType' xmlns='urn:ebay:api:PayPalAPI'>
      <Credentials xsi:type='ebl:UserIdPasswordType' xmlns='urn:ebay:apis:eBLBaseComponents'>
        <Username xsi:type='xs:string'/>
        <Password xsi:type='xs:string'/>
        <Subject xsi:type='xs:string'/>
      </Credentials>
    </RequesterCredentials>
  </SOAP-ENV:Header>
  <SOAP-ENV:Body id='_0'>
    <DoExpressCheckoutPaymentResponse xmlns='urn:ebay:api:PayPalAPI'>
      <Timestamp xmlns='urn:ebay:apis:eBLBaseComponents'>2007-02-13T00:18:50Z</Timestamp>
      <Ack xmlns='urn:ebay:apis:eBLBaseComponents'>Success</Ack>
      <CorrelationID xmlns='urn:ebay:apis:eBLBaseComponents'>62450a4266d04</CorrelationID>
      <Version xmlns='urn:ebay:apis:eBLBaseComponents'>2.000000</Version>
      <Build xmlns='urn:ebay:apis:eBLBaseComponents'>1.0006</Build>
      <DoExpressCheckoutPaymentResponseDetails xsi:type='ebl:DoExpressCheckoutPaymentResponseDetailsType' xmlns='urn:ebay:apis:eBLBaseComponents'>
        <Token xsi:type='ebl:ExpressCheckoutTokenType'>EC-6WS104951Y388951L</Token>
        <PaymentInfo xsi:type='ebl:PaymentInfoType'>
          <TransactionID>8B266858CH956410C</TransactionID>
          <ParentTransactionID xsi:type='ebl:TransactionId'/>
          <ReceiptID/>
          <TransactionType xsi:type='ebl:PaymentTransactionCodeType'>express-checkout</TransactionType>
          <PaymentType xsi:type='ebl:PaymentCodeType'>instant</PaymentType>
          <PaymentDate xsi:type='xs:dateTime'>2007-02-13T00:18:48Z</PaymentDate>
          <GrossAmount currencyID='USD' xsi:type='cc:BasicAmountType'>3.00</GrossAmount>
          <TaxAmount currencyID='USD' xsi:type='cc:BasicAmountType'>0.00</TaxAmount>
          <ExchangeRate xsi:type='xs:string'/>
          <PaymentStatus xsi:type='ebl:PaymentStatusCodeType'>Pending</PaymentStatus>
          <PendingReason xsi:type='ebl:PendingStatusCodeType'>authorization</PendingReason>
          <ReasonCode xsi:type='ebl:ReversalReasonCodeType'>none</ReasonCode>
        </PaymentInfo>
      </DoExpressCheckoutPaymentResponseDetails>
    </DoExpressCheckoutPaymentResponse>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
    RESPONSE
  end
end
