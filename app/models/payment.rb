# == Schema Information
#
# Table name: payments
#
#  id         :integer          not null, primary key
#  payer_data :text
#  reference  :string
#  amount     :decimal(12, 3)
#  status     :integer          default(0)
#  archive_id :string
#  message    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Payment < ApplicationRecord

  require 'openssl'
  include SisXmlTemplate

  MAC_FIELDS = ['VERSION', 'STAMP', 'AMOUNT', 'REFERENCE', 'MESSAGE',
    'LANGUAGE', 'MERCHANT', 'RETURN', 'CANCEL', 'REJECT',
    'DELAYED', 'COUNTRY', 'CURRENCY', 'DEVICE', 'CONTENT',
    'TYPE', 'ALGORITHM', 'DELIVERY_DATE', 'FIRSTNAME', 'FAMILYNAME',
    'ADDRESS', 'POSTCODE', 'POSTOFFICE']

  RETURN_URL_FIELDS = ['VERSION', 'STAMP', 'REFERENCE', 'PAYMENT', 'STATUS', 'ALGORITHM']

  URL = 'https://payment.checkout.fi:443/'

  DEFAULTS = {
    'VERSION'       => '0001',
    'STAMP'         => '', # Unique value
    'AMOUNT'        => '',
    'REFERENCE'     => '',
    'MESSAGE'       => '',
    'LANGUAGE'      => 'FI',
    'RETURN'        => '',
    'CANCEL'        => '',
    'REJECT'        => '',
    'DELAYED'       => '',
    'COUNTRY'       => 'FIN',
    'CURRENCY'      => 'EUR',
    'DEVICE'        => '10', # 10 = XML
    'CONTENT'       => '1',
    'TYPE'          => '0',
    'ALGORITHM'     => '3',
    'DELIVERY_DATE' => '',
    'FIRSTNAME'     => '',
    'FAMILYNAME'    => '',
    'ADDRESS'       => '',
    'POSTCODE'      => '',
    'POSTOFFICE'    => '',
    'MAC'           => '',
    'EMAIL'         => '',
    'PHONE'         => ''
  }

  PAYER_DATA_FIELDS= ['FIRSTNAME', 'FAMILYNAME', 'ADDRESS', 'POSTCODE', 'POSTOFFICE', 'EMAIL', 'PHONE']

  serialize :payer_data, Hash

  validates :amount, presence: true, numericality:{ greater_than:0 }
  validates :status, presence: true
  validates :reference, presence: true
  validate  :check_payer_data 

  attr_accessor :merchant_data
  attr_accessor :urls

   # string merchant - Merchant ID
   # string password - Merchant sercret key
  def set_merchant_data(merchant_id, password, aggregator_id=0)
    @merchant_data = {
        'AGGREGATOR' => aggregator_id,
        'MERCHANT'   => merchant_id,
        'SECRET_KEY' => password
    }
  end


  # Perform HTTP POST
  def post(url, payload)

    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data(payload)
    puts "REQUEST #{request.inspect}"
    response = http.request(request)    
    puts "RESPONSE: #{response.inspect}"
    return response    

    # $options = array(
    #     CURLOPT_POST           => 1,
    #     CURLOPT_HEADER         => 0,
    #     CURLOPT_URL            => $url,
    #     CURLOPT_FRESH_CONNECT  => 1,
    #     CURLOPT_RETURNTRANSFER => 1,
    #     CURLOPT_FORBID_REUSE   => 1,
    #     CURLOPT_TIMEOUT        => 20,
    #     CURLOPT_POSTFIELDS     => http_build_query($payload)
    # );

    # $ch = curl_init();
    # curl_setopt_array($ch, $options);
    # $result = curl_exec($ch);
    # curl_close($ch);

    # return $result;

  end
 

  # Get payment button XML
  # Hash data  - hash containing non-default data
  def get_payment_buttons
    post_data=self.get_data
    return self.post(URL, post_data)
    #return self::post(self::$URL, $this->getData($data));
  end

  def sis_checkout
    attrs={
      :aggregator => self.merchant_data['AGGREGATOR'],
      :reference => self.reference,
      :description => self.message,
      :stamp => Time.now.to_i,
      :vat => 24,
      :merchant_id => self.merchant_data['MERCHANT'],
      :amount => (self.amount*100).to_i,
      :buyer_firstname => self.payer_data['FIRSTNAME'], 
      :buyer_familyname => self.payer_data['FAMILYNAME'],
      :buyer_street => self.payer_data['ADDRESS'],
      :buyer_postcode => self.payer_data['POSTCODE'],
      :buyer_city => self.payer_data['POSTOFFICE'],
      :buyer_country => 'FIN',
      :buyer_email => self.payer_data['EMAIL'],
      :buyer_phone => self.payer_data['PHONE'],
      :buyer_language => 'FI',
      :delivery_date => Time.now.strftime('%Y%m%d'),
      :control_return => self.urls['RETURN'],
      :control_reject => self.urls['CANCEL'],
      :control_cancel => self.urls['CANCEL'],  
    }
    post_data={}
    post_data['CHECKOUT_XML']=sis_request_xml(attrs)
    puts post_data['CHECKOUT_XML']
    post_data['CHECKOUT_XML']=Base64.encode64(post_data['CHECKOUT_XML'])
    post_data['CHECKOUT_MAC']=OpenSSL::Digest::SHA256.hexdigest(post_data['CHECKOUT_XML']+'+'+self.merchant_data['SECRET_KEY']).upcase
    return self.post(URL, post_data)
  end

  # Validate return URL signature
  # array queryParams - Query string parameters from the return URL
  def validate_return_url_signature(query_params)
    hash_string=RETURN_URL_FIELDS.map { |field| query_params[field] }.join('&')
    secure_hash=OpenSSL::HMAC.hexdigest("SHA256", self.merchant_data['SECRET_KEY'], hash_string ).upcase
    puts hash_string
    puts secure_hash
    return query_params['MAC'] == secure_hash
    # $hashString = join(
    #     '&',
    #     array_map(
    #         function ($field) use (&$queryParams) {
    #             return $queryParams[$field];
    #         },
    #         self::$RETURN_URL_FIELDS
    #     )
    # );
    # $calculatedMac = strtoupper(hash_hmac('sha256', $hashString, $this->merchantData['SECRET_KEY']));
    # return $calculatedMac === $queryParams['MAC'];
  end

  # Merge defaults with given data, and calculate MAC for the data. 
  # MAC calculation is done by joining all values in correct order using '+',
  # and then calculating SHA-256 sum of the resulting string.

  def get_data
    payment_data = {
      'STAMP'         => Time.now.to_i, 
      'REFERENCE'     => self.reference,
      'MESSAGE'       => self.message,
      'RETURN'        => self.urls['RETURN'],
      'CANCEL'        => self.urls['CANCEL'],
      'AMOUNT'        => (self.amount*100).to_i, # Price in cents
      'DELIVERY_DATE' => Time.now.strftime('%Y%m%d'),
      'MERCHANT'      => self.merchant_data['MERCHANT']
    }
    # payment_data = {
    #   'STAMP'         => , 
    #   'REFERENCE'     => '12344',
    #   'MESSAGE'       => "Furniture materials\nWoodworking tools",
    #   'RETURN'        => self.urls['RETURN'],
    #   'CANCEL'        => self.urls['CANCEL'],
    #   'AMOUNT'        => '1000', # Price in cents
    #   'DELIVERY_DATE' => Time.now.strftime('%Y%m%d'),
    #   'MERCHANT'      => self.merchant_data['MERCHANT']
    # }    

    parameters = DEFAULTS.merge(payment_data)
    Payment::PAYER_DATA_FIELDS.each do |field|
      payment_data[field]=self.payer_data[field]
    end

    digest_string = MAC_FIELDS.map{ |field| parameters[field] }.join('+')
    digest_string +="+"+self.merchant_data['SECRET_KEY']
    parameters['MAC']=OpenSSL::Digest::SHA256.hexdigest(digest_string)
    return parameters
    # $parameters = array_merge(
    #     self::$DEFAULTS,
    #     $data,
    #     array('MERCHANT' => $this->merchantData['MERCHANT'])
    # );
    # $hashString = join(
    #     '+',
    #     array_map(
    #         function ($field) use (&$parameters) {
    #             return $parameters[$field];
    #         },
    #         self::$MAC_FIELDS
    #     )
    # );
    # // Calculate MAC
    # $parameters['MAC'] = hash('sha256', $hashString . '+' . $this->merchantData['SECRET_KEY']);
    # return $parameters;
  end

  def check_payer_data
    PAYER_DATA_FIELDS.each do |field|
      errors.add(:payer_data, "field #{field.downcase} cannot be empty") if self.payer_data[field].blank?
    end
  end

  def is_paid?
    return [2, 4, 5, 6, 7, 8, 9, 10].include?(self.status)
  end

  def status_text
    return self.is_paid? ? "paid" : "not paid"
  end  

end
