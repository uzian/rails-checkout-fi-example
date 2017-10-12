class Payment < ApplicationRecord

  require 'openssl'

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
  validate :check_payer_data 

  attr_accessor :merchant_data

   # string merchant - Merchant ID
   # string password - Merchant sercret key
  def set_merchant_data(merchant_id, password)
    @merchant_data = {
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
  def get_payment_buttons(data)
    post_data=self.get_data(data)
    puts "POST DATA #{post_data.inspect}"
    return self.post(URL, post_data)
    #return self::post(self::$URL, $this->getData($data));
  end

  # Validate return URL signature
  # array queryParams - Query string parameters from the return URL
  def validate_return_url_signature(query_params)
    hash_string=RETURN_URL_FIELDS.map { |field| query_params[field] }.join('&')
    secure_hash=OpenSSL::HMAC.hexdigest("SHA256", hash_string, self.merchant_data['SECRET_KEY'])
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

  def get_data(data)
    parameters = DEFAULTS.merge(data).merge({'MERCHANT' => self.merchant_data['MERCHANT']})
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

  def is_paid(status)
    return [2, 4, 5, 6, 7, 8, 9, 10].includes?(status)
  end

end
