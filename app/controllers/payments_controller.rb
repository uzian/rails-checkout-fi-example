class PaymentsController < ApplicationController
  require "awesome_print"

  before_action :set_payment, only: [:show, :edit, :update, :destroy]

  # GET /payments
  # GET /payments.json
  def index
    @payments = Payment.all
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
  end

  # GET /payments/new
  def new
    @payment=Payment.new    

    order_data = {
      'STAMP'         => Time.now.to_i, # Unique timestamp
      'REFERENCE'     => '12344',
      'MESSAGE'       => "Furniture materials\nWoodworking tools",
      'RETURN'        => 'http://example.com/return',
      'CANCEL'        => 'http://exaple.com/cancel',
      'AMOUNT'        => '1000', # Price in cents
      'DELIVERY_DATE' => Time.now.strftime('%Y%m%d'),
      'FIRSTNAME'     => 'Matti',
      'FAMILYNAME'    => 'Meikäläinen',
      'ADDRESS'       => "Ääkköstie 5 b 3\nGround floor",
      'POSTCODE'      => '33100',
      'POSTOFFICE'    => 'Tampere',
      'EMAIL'         => 'support@checkout.fi',
      'PHONE'         => '0800 552 010'
    }

    checkout = Checkout.new(375917, 'SAIPPUAKAUPPIAS')
    response=checkout.get_payment_buttons(order_data)

    @xml_hash=Hash.from_xml(response.body)
    @banks={}
    trade=@xml_hash["trade"]
    if trade
      payments=trade["payments"]
      if payments
        payment=payments["payment"]
        if payment
          banks=payment["banks"]
          @banks=banks unless banks.nil?
        end
      end
    end
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1
  # PATCH/PUT /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to payments_url, notice: 'Payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.require(:payment).permit(:first_name, :last_name, :last4, :amount, :success, :authorization_code)
    end
end

var=
{"trade"=>{"id"=>"64934395", "description"=>"Furniture materials\nWoodworking tools", "status"=>"1", "returnURL"=>"http://example.com/return", "returnMAC"=>nil, "cancelURL"=>"http://exaple.com/cancel", "cancelMAC"=>"E10F4796496105E01883CBA2AD0C636124767CD2A3FD6CCD303470844705BF39", "rejectURL"=>nil, "delayedURL"=>nil, "delayedMAC"=>"0926F78B139258A305AA0EEBEE68024773C55EB4F22F3BA4E1D3C7170356C101", "stamp"=>"1507752191", "version"=>"0001", "reference"=>"12344", "language"=>"FI", "content"=>"1", "deliveryDate"=>"20171011", "firstname"=>"Matti", "familyname"=>"Meikäläinen", "address"=>"Ääkköstie 5 b 3\nGround floor", "postcode"=>"33100", "postoffice"=>"Tampere", "country"=>"FIN", "device"=>"10", "type"=>"0", "algorithm"=>"3", "paymentURL"=>"https://payment.checkout.fi/p/64934395/103C3F96-DB854989-0ED733AA-C8B98F43-4C870137-6CBBFD89-CE55E19F-C95D4145", "customerEmail"=>"support@checkout.fi", "customerPhone"=>"0800 552 010", "merchant"=>{"id"=>"375917", "company"=>"Testi Oy", "name"=>"Markkinointinimi", "email"=>"testi@checkout.fi", "address"=>"Testikuja 1\r\n12345 Testilä", "vatId"=>"123456-7", "helpdeskNumber"=>"012-345 678"}, "payments"=>{"payment"=>{"id"=>"65318735", "amount"=>"1000", "stamp"=>"1507752191", "banks"=>{"mobilepay"=>{"url"=>"https://v1-hub-staging.sph-test-solinor.com/form/view/mobilepay", "icon"=>"https://payment.checkout.fi/static/img/mobilepay_140x75.png", "name"=>"MobilePay", "sph_account"=>"test", "sph_merchant"=>"test_merchantId", "sph_order"=>"CO65318735", "sph_request_id"=>"0f21aa86-0de6-4705-9181-29efc0b33edc", "sph_amount"=>"1000", "sph_currency"=>"EUR", "sph_timestamp"=>"2017-10-11T20:03:12Z", "sph_success_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirmer?solinorMethod=mobilepay", "sph_failure_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel?solinorMethod=mobilepay", "sph_cancel_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/back?solinorMethod=mobilepay", "sph_sub_merchant_id"=>"375917", "language"=>"FI", "signature"=>"SPH1 testKey 34637fa7e5e43f6bd667106a8e6a55537a3821356968519cd1e9409492f560ff"}, "osuuspankki"=>{"url"=>"https://kultaraha.op.fi/cgi-bin/krcgi", "icon"=>"https://payment.checkout.fi//static/img/op_140x75.png", "name"=>"Osuuspankki", "VALUUTTALAJI"=>"EUR", "VIITE"=>"653187354", "MAKSUTUNNUS"=>"64934395", "action_id"=>"701", "MYYJA"=>"Esittelymyyja", "SUMMA"=>"10.00", "VIESTI"=>"Testi Henkilö", "TARKISTE"=>"4BAF5133815FEEB619943EF43D951DBA", "PALUU_LINKKI"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm", "VERSIO"=>"1", "TARKISTE_VERSIO"=>"1", "VAHVISTUS"=>"K", "PERUUTUS_LINKKI"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel"}, "nordea"=>{"url"=>"https://epmt.nordea.fi/cgi-bin/SOLOPM01", "icon"=>"https://payment.checkout.fi//static/img/nordea_140x75.png", "name"=>"Nordea", "SOLOPMT_VERSION"=>"0003", "SOLOPMT_RCV_ID"=>"12345678", "SOLOPMT_CUR"=>"EUR", "SOLOPMT_LANGUAGE"=>"1", "SOLOPMT_RCV_ACCOUNT"=>nil, "SOLOPMT_REJECT"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/reject", "SOLOPMT_CONFIRM"=>"YES", "SOLOPMT_CANCEL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "SOLOPMT_RCV_NAME"=>"Checkout Oy", "SOLOPMT_DATE"=>"EXPRESS", "SOLOPMT_AMOUNT"=>"10.00", "SOLOPMT_REF"=>"653187354", "SOLOPMT_MSG"=>"Testi Henkilö", "SOLOPMT_MAC"=>"ABFCDD97083A1CEDAC212C0F1BA8E937", "SOLOPMT_STAMP"=>"64934395", "SOLOPMT_RETURN"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm", "SOLOPMT_KEYVERS"=>"0001"}, "handelsbanken"=>{"url"=>"https://verkkomaksu.inetpankki.samlink.fi/vm/SHBlogin.html", "icon"=>"https://payment.checkout.fi//static/img/handelsbanken_140x75.png", "name"=>"Handelsbanken", "NET_VERSION"=>"002", "NET_SELLER_ID"=>"0000000000", "NET_CUR"=>"EUR", "NET_REJECT"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/reject", "NET_CONFIRM"=>"YES", "NET_CANCEL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "NET_DATE"=>"EXPRESS", "NET_AMOUNT"=>"10,00", "NET_REF"=>"653187354", "NET_MSG"=>"Testi Henkilö", "NET_MAC"=>"2D17EEB66DBDA4BA369B2C3A016E98AB", "NET_STAMP"=>"64934395", "NET_RETURN"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm"}, "poppankki"=>{"url"=>"https://verkkomaksu.poppankki.fi/vm/login.html", "icon"=>"https://payment.checkout.fi/static/img/poppankki_140x75.png", "name"=>"POP-Pankki", "NET_VERSION"=>"003", "NET_SELLER_ID"=>"0000000000", "NET_CUR"=>"EUR", "NET_REJECT"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/reject", "NET_CONFIRM"=>"YES", "NET_CANCEL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "NET_DATE"=>"EXPRESS", "NET_AMOUNT"=>"10,00", "NET_REF"=>"653187354", "NET_MSG"=>"Testi Henkilö", "NET_MAC"=>"C44805C603D2FCA3A543F31EE20D8F2EA69EBDFEF4DADB32795CC0C7ECFE82BA", "NET_STAMP"=>"64934395", "NET_RETURN"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm", "NET_ALG"=>"03"}, "aktia"=>{"url"=>"https://auth.aktia.fi/vmtest", "icon"=>"https://payment.checkout.fi/static/img/aktia_140x75.png", "name"=>"Aktia", "NET_VERSION"=>"010", "NET_SELLER_ID"=>"1111111111111", "NET_CUR"=>"EUR", "NET_REJECT"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/reject", "NET_CONFIRM"=>"YES", "NET_CANCEL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "NET_DATE"=>"EXPRESS", "NET_AMOUNT"=>"10,00", "NET_REF"=>"653187354", "NET_MSG"=>"Testi Henkilö", "NET_MAC"=>"E48B4B8E15C1F79638722A52D2ED8CD5551A8284648B484A09246870280DFF7D", "NET_STAMP"=>"64934395", "NET_RETURN"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm", "NET_KEYVERS"=>"0003", "NET_ALG"=>"03"}, "saastopankki"=>{"url"=>"https://verkkomaksu.saastopankki.fi/vm/login.html", "icon"=>"https://payment.checkout.fi/static/img/saastopankki_140x75.png", "name"=>"Säästöpankki", "NET_VERSION"=>"003", "NET_SELLER_ID"=>"0021966066003", "NET_CUR"=>"EUR", "NET_REJECT"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/reject", "NET_CONFIRM"=>"YES", "NET_CANCEL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "NET_DATE"=>"EXPRESS", "NET_AMOUNT"=>"10,00", "NET_REF"=>"653187354", "NET_MSG"=>"Testi Henkilö", "NET_MAC"=>"069616DE6DC106F2437D9C2F1C7EDB789DFF95BE7A96E099CC99AABA0197B8AB", "NET_STAMP"=>"64934395", "NET_RETURN"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm", "NET_ALG"=>"03"}, "omasp"=>{"url"=>"https://verkkomaksu.omasp.fi/vm/login.html", "icon"=>"https://payment.checkout.fi//static/img/omasp_140x75.png", "name"=>"SP/OmaSp", "NET_VERSION"=>"003", "NET_SELLER_ID"=>"0000000000", "NET_CUR"=>"EUR", "NET_REJECT"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/reject", "NET_CONFIRM"=>"YES", "NET_CANCEL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "NET_DATE"=>"EXPRESS", "NET_AMOUNT"=>"10,00", "NET_REF"=>"653187354", "NET_MSG"=>"Testi Henkilö", "NET_MAC"=>"C44805C603D2FCA3A543F31EE20D8F2EA69EBDFEF4DADB32795CC0C7ECFE82BA", "NET_STAMP"=>"64934395", "NET_RETURN"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm", "NET_ALG"=>"03"}, "spankki"=>{"url"=>"https://online.s-pankki.fi/service/paybutton", "icon"=>"https://payment.checkout.fi//static/img/s-pankki_140x75.png", "name"=>"S-Pankki", "AAB_VERSION"=>"0002", "AAB_STAMP"=>"64934395", "AAB_RCV_ID"=>"SPANKKIESHOPID", "AAB_RCV_ACCOUNT"=>"393900-01002369", "AAB_RCV_NAME"=>"CHECKOUT FINLAND OY", "AAB_LANGUAGE"=>"1", "AAB_AMOUNT"=>"10,00", "AAB_REF"=>"653187354", "AAB_DATE"=>"EXPRESS", "AAB_MSG"=>"Testi Henkilö", "AAB_RETURN"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm", "AAB_CANCEL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "AAB_REJECT"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/reject", "AAB_MAC"=>"0800D018181B417B8DC282B43CDC0828", "AAB_CONFIRM"=>"YES", "AAB_KEYVERS"=>"0001", "AAB_CUR"=>"EUR"}, "alandsbanken"=>{"url"=>"https://online.alandsbanken.fi/aab/ebank/auth/initLogin.do?BV_UseBVCookie=no", "icon"=>"https://payment.checkout.fi//static/img/alandsbanken_140x75.png", "name"=>"Ålandsbanken", "AAB_VERSION"=>"0002", "AAB_STAMP"=>"64934395", "AAB_RCV_ID"=>"AABESHOPID", "AAB_RCV_ACCOUNT"=>"660100-1130855", "AAB_RCV_NAME"=>"Checkout", "AAB_LANGUAGE"=>"1", "AAB_AMOUNT"=>"10,00", "AAB_REF"=>"653187354", "AAB_DATE"=>"EXPRESS", "AAB_MSG"=>"Testi Henkilö", "AAB_RETURN"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm", "AAB_CANCEL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "AAB_REJECT"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/reject", "AAB_MAC"=>"E04BDA70C05B0005E50347E4220366DA", "AAB_CONFIRM"=>"YES", "AAB_KEYVERS"=>"0001", "AAB_CUR"=>"EUR", "AAB_ALG"=>nil, "BV_UseBVCookie"=>"no"}, "sampo"=>{"url"=>"https://verkkopankki.danskebank.fi/SP/vemaha/VemahaApp", "icon"=>"https://payment.checkout.fi//static/img/danskebank_140x75.png", "name"=>"Danske Bank", "SUMMA"=>"10.00", "VIITE"=>"653187354", "KNRO"=>"000000000000", "VALUUTTA"=>"EUR", "VERSIO"=>"3", "OKURL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirm?ORDER=64934395&ORDERMAC=0F70207FC4F33A42E5367CC4C91FAD63", "VIRHEURL"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel", "TARKISTE"=>"6f25a65d97621dece9bb76d187d8e150dce9c0dac27c56f05bac03d5bd9a4cbb", "ERAPAIVA"=>"11.10.2017", "ALG"=>"03", "lng"=>"1"}, "solinor"=>{"url"=>"https://v1-hub-staging.sph-test-solinor.com//form/view/pay_with_card", "icon"=>"https://payment.checkout.fi//static/img/visa_140x75.png", "name"=>"Visa", "sph_order"=>"CO65318735", "sph_merchant"=>"test_merchantId", "sph_amount"=>"1000", "sph_failure_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel?solinorMethod=cc", "sph_timestamp"=>"2017-10-11T20:03:12Z", "sph_currency"=>"EUR", "sph_cancel_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/back?solinorMethod=cc", "sph_account"=>"test", "sph_request_id"=>"199b6ba8-a357-4a5e-ba56-b6e3b2e99e53", "sph_success_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirmer?solinorMethod=cc", "signature"=>"SPH1 testKey 067c475866ae52da351032c83f5f7b6276b9b7daa0d3710c39fc518f828c47a3"}, "solinor2"=>{"url"=>"https://v1-hub-staging.sph-test-solinor.com//form/view/pay_with_card", "icon"=>"https://payment.checkout.fi//static/img/visae.gif", "name"=>"Visa Electron", "sph_order"=>"CO65318735", "sph_merchant"=>"test_merchantId", "sph_amount"=>"1000", "sph_failure_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel?solinorMethod=cc", "sph_timestamp"=>"2017-10-11T20:03:12Z", "sph_currency"=>"EUR", "sph_cancel_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/back?solinorMethod=cc", "sph_account"=>"test", "sph_request_id"=>"199b6ba8-a357-4a5e-ba56-b6e3b2e99e53", "sph_success_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirmer?solinorMethod=cc", "signature"=>"SPH1 testKey 067c475866ae52da351032c83f5f7b6276b9b7daa0d3710c39fc518f828c47a3"}, "solinor3"=>{"url"=>"https://v1-hub-staging.sph-test-solinor.com//form/view/pay_with_card", "icon"=>"https://payment.checkout.fi//static/img/mastercard_140x75.png", "name"=>"Mastercard", "sph_order"=>"CO65318735", "sph_merchant"=>"test_merchantId", "sph_amount"=>"1000", "sph_failure_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/cancel?solinorMethod=cc", "sph_timestamp"=>"2017-10-11T20:03:12Z", "sph_currency"=>"EUR", "sph_cancel_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/back?solinorMethod=cc", "sph_account"=>"test", "sph_request_id"=>"199b6ba8-a357-4a5e-ba56-b6e3b2e99e53", "sph_success_url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/confirmer?solinorMethod=cc", "signature"=>"SPH1 testKey 067c475866ae52da351032c83f5f7b6276b9b7daa0d3710c39fc518f828c47a3"}, "svea"=>{"url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/svea", "icon"=>"https://payment.checkout.fi/static/img/svea_140x75pix_001.png", "name"=>"SveaWebPay lasku"}, "sveab2blasku"=>{"url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/sveab2blasku", "icon"=>"https://payment.checkout.fi/static/img/B2BLasku_cmyk.jpg", "name"=>"SveaWebPay B2B-lasku"}, "euroloan"=>{"url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/euroloan", "icon"=>"https://payment.checkout.fi/static/img/euroloan_140x75.png", "name"=>"Euroloan", "__content__"=>"\n "}, "tilisiirto"=>{"url"=>"https://payment.checkout.fi/zZgFqR7mGf/fi/tilisiirto", "icon"=>"https://payment.checkout.fi//static/img/tilisiirto.gif", "name"=>"Tilisiirto", "bank"=>"Nordea", "iban"=>"FI66 1732 3000 0094 95", "bic"=>"NDEAFIHH", "reference"=>"653187354", "amount"=>"1000", "receiver"=>"Checkout Finland Oy"}}}}}}
