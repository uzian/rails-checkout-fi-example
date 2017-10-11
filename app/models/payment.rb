class Payment < ApplicationRecord

  # attr_accessor :version
  # attr_accessor :language
  # attr_accessor :country
  # attr_accessor :currency
  # attr_accessor :device
  # attr_accessor :content
  # attr_accessor :type
  # attr_accessor :algorithm
  # attr_accessor :merchant
  # attr_accessor :password
  # attr_accessor :stamp
  # attr_accessor :amount
  # attr_accessor :reference
  # attr_accessor :message
  # attr_accessor :return_
  # attr_accessor :cancel
  # attr_accessor :reject
  # attr_accessor :delayed
  # attr_accessor :delivery_date
  # attr_accessor :firstname
  # attr_accessor :familyname
  # attr_accessor :address
  # attr_accessor :postcode
  # attr_accessor :postoffice
  # attr_accessor :status
  # attr_accessor :email 
  # attr_accessor :phone


  
  # # def set_defaults(new_merchant, new_password) 
  # #   self.merchant = new_merchant # merchant id
  # #   self.password = new_password # security key (about 80 chars)
  # #   DEFAULTS.each do |key,value|
  # #     self.set_property(key,value)
  # #   end
  # # end

  # def set_property(name, value)
  #   prop_name = "@#{name}".to_sym # you need the property name, prefixed with a '@', as a symbol
  #   self.instance_variable_set(prop_name, value)
  # end

  # # generates MAC and prepares values for creating payment

  # def getCheckoutObject(data) 
  #   #overwrite default values
  #   data.each do |key,value| 
  #     self.send(key) = value
  #   end

  #   mac_fields=%w( version stamp amount reference message language merchant return_ cancel reject delayed country currency device content type algorithm delivery_date firstname familyname address postcode postoffice password )
  #   mac_string=mac_fields.map{|k| "{#{self.send(k)}}"}.join("+")

  #   mac = Digest::MD5.hexdigest(mac_string).upcase 

  #   post={}
  #   DEFAULTS.keys do |key|
  #     post['#{key.upcase}']=self.send(key)
  #   end
  #   post['RETURN']=post['_RETURN']
  #   post.delete('_RETURN')
  #   post.delete('STATUS')
  #   post['MAC']=mac_string

  #   return post
  # end

  # # returns payment information in XML
  # def getCheckoutXML(data) 
  #   self.device = "10"
  #   return self.sendPost(self.getCheckoutObject(data))
  # end

  # def sendPost(post) 
  #   http = Net::HTTP.new("payment.checkout.fi")
  #   http.use_ssl = true
  #   request = Net::HTTP::Post.new("/", {'Content-Type' => 'application/json'})
  #   request.body = post.to_json
  #   response = http.request(request)    
  #   return response
  # end

  # #string hash_hmac ( string $algo , string $data , string $key [, bool $raw_output = false ] )    
  # #Digest::HMAC.hexdigest("data", "hash key", Digest::SHA1)


  # def validateCheckout(data) 
  #   generatedMac=Digest::HMAC.hexdigest("{#{data['VERSION']}}&{#{data['STAMP']}}&{#{data['REFERENCE']}}&{#{data['PAYMENT']}}&{#{data['STATUS']}}&{#{data['ALGORITHM']}}", self.password, Digest::SHA256)
  #   return data['MAC'] == generatedMac
  # end


  # def isPaid(status)
  #   return [2, 4, 5, 6, 7, 8, 9, 10].includes?(status)
  # end

end
