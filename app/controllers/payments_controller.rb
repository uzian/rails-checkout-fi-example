class PaymentsController < ApplicationController
  require "awesome_print"

  before_action :set_payment, only: [:show, :destroy, :checkout, :cancel]

  # GET /payments
  # GET /payments.json
  def index
    @payments = Payment.all
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
    if !params['MAC'].nil? 
      @payment.set_merchant_data(375917, 'SAIPPUAKAUPPIAS')
      if @payment.validate_return_url_signature(params)
        @result="Checkout transaction MAC CHECK OK, payment status: #{@payment.status_text} "
        @payment.update(status:params['STATUS'].to_i, archive_id: params['PAYMENT'] )
      else 
        @result= "Checkout transaction MAC CHECK Failed."
      end
    end
  end

  def checkout
    @payment.set_merchant_data(375917, 'SAIPPUAKAUPPIAS')
    @payment.urls={'RETURN' => payment_url(@payment), 'CANCEL' => cancel_payment_url(@payment)}
    response=@payment.get_payment_buttons
    @banks={}
    begin
      @xml_hash=Hash.from_xml(response.body)
    rescue 
      @error_text=response.body
      @xml_hash={}
      return
    end 
    return unless trade=@xml_hash["trade"]
    return unless payments=trade["payments"]
    return unless payment=payments["payment"]
    return unless banks=payment["banks"]
    @banks=banks unless banks.nil?    
  end

  # GET /payments/new
  def new
    payer_data={   
      'FIRSTNAME'     => Faker::Name.first_name,
      'FAMILYNAME'    => Faker::Name.last_name,
      'ADDRESS'       => Faker::Address.street_address,
      'POSTCODE'      => Faker::Address.postcode,
      'POSTOFFICE'    => Faker::Address.city ,
      'EMAIL'         => 'support@checkout.fi',
      'PHONE'         => Faker::PhoneNumber.phone_number
    }
    # payer_data={
    #   'FIRSTNAME'     => 'Matti',
    #   'FAMILYNAME'    => 'Meikäläinen',
    #   'ADDRESS'       => "Ääkköstie 5 b 3\nGround floor",
    #   'POSTCODE'      => '33100',
    #   'POSTOFFICE'    => 'Tampere',
    #   'EMAIL'         => 'support@checkout.fi',
    #   'PHONE'         => '0800 552 010'      
    # }
    session[:price]=Faker::Commerce.price*100 
    session[:reference]=Time.now.to_i
    session[:message]=Faker::Commerce.product_name    

    # session[:price]=1000 
    # session[:reference]='12344'
    # session[:message]="Furniture materials\nWoodworking tools"    

    @payment=Payment.new( 
      amount: session[:price], 
      reference: session[:reference],
      message: session[:message],
      payer_data: payer_data)     
  end


  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(amount: session[:price].to_i, reference: session['reference'], message: session['message'])
    Payment::PAYER_DATA_FIELDS.each do |field|
      @payment.payer_data[field]=params["payer_data_#{field.downcase}"]
    end

    respond_to do |format|
      if @payment.save
        format.html { redirect_to checkout_payment_path(@payment), notice: 'Payment proceeding' }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new }
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

  def cancel
    if !params['MAC'].nil? 
      @payment.set_merchant_data(375917, 'SAIPPUAKAUPPIAS')
      if @payment.validate_return_url_signature(params)
        @result="Checkout transaction MAC CHECK OK, payment status: #{@payment.status_text} "
        @payment.update(status:params['STATUS'].to_i, archive_id: params['PAYMENT'] )
      else 
        @result= "Checkout transaction MAC CHECK Failed."
      end
    end    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find_by_id(params[:id].to_i)
      redirect_to root_path, flash:{ error: "Invalid payment id" } if @payment.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.require(:payment).permit( :payer_data)
    end

end
