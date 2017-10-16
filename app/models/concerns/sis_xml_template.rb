module SisXmlTemplate

  extend ActiveSupport::Concern

  def sis_request_xml(attrs)
    return "<?xml version=\"1.0\"?>
      <checkout xmlns=\"http://checkout.fi/request\">
          <request type=\"aggregator\" test=\"true\">
              <aggregator>#{attrs[:aggregator]}</aggregator>
              <version>0002</version>
              <stamp>#{attrs[:stamp]}</stamp>
              <reference>#{attrs[:reference]}</reference>
              <description>#{attrs[:description]}</description>
              <device>10</device>
              <content>1</content>
              <type>0</type>
              <algorithm>3</algorithm>
              <currency>EUR</currency>
              <items>
                  <item>
                      <code/>
                      <description>#{attrs[:description]}</description>
                      <price currency=\"EUR\" vat=\"#{attrs[:vat]}\">#{attrs[:amount]}</price>
                      <merchant>#{attrs[:merchant_id]}</merchant>
                      <control/>
                  </item>
                  <amount currency=\"EUR\">#{attrs[:amount]}</amount>
              </items>
              <buyer>
                  <firstname>#{attrs[:buyer_firstname]}</firstname>
                  <familyname>#{attrs[:buyer_familyname]}</familyname>
                  <address>#{attrs[:buyer_street]}</address>
                  <postalcode>#{attrs[:buyer_postcode]}</postalcode>
                  <postaloffice>#{attrs[:buyer_city]}</postaloffice>
                  <country>#{attrs[:buyer_country]}</country>
                  <email>#{attrs[:buyer_email]}</email>
                  <gsm>#{attrs[:buyer_phone]}</gsm>
                  <language>#{attrs[:buyer_language]}</language>
              </buyer>
              <delivery>
                  <date>#{attrs[:delivery_date]}</date>
              </delivery>
              <control type=\"default\">
                  <return>#{attrs[:control_return]}</return>
                  <reject>#{attrs[:control_reject]}</reject>
                  <cancel>#{attrs[:control_cancel]}</cancel>
              </control>
          </request>
      </checkout>"
  end

end