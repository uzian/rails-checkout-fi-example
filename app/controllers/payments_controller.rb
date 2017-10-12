class PaymentsController < ApplicationController
  require "awesome_print"

  before_action :set_payment, only: [:show, :edit, :update, :destroy, :checkout, :cancel]

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
        @result="Checkout transaction MAC CHECK OK, payment status =  "
        if @payment.is_paid(params['STATUS']) 
          @result += "Paid."
          @payment.update(status:1)
        else 
          @result+= "Not paid."
          @payment.update(status:2)
        end
      else 
        @result= "Checkout transaction MAC CHECK Failed."
      end
    end
  end

  def checkout
    @order_data = {
      'STAMP'         => @payment.id, # Unique timestamp
      'REFERENCE'     => '12344',
      'MESSAGE'       => "Furniture materials\nWoodworking tools",
      'RETURN'        => payment_url(@payment),
      'CANCEL'        => cancel_payment_url(@payment),
      'AMOUNT'        => @payment.amount, # Price in cents
      'DELIVERY_DATE' => Time.now.strftime('%Y%m%d'),
    }
    Payment::PAYER_DATA_FIELDS.each do |field|
      @order_data[field]=@payment.payer_data[field]
    end

    @payment.set_merchant_data(375917, 'SAIPPUAKAUPPIAS')
    response=@payment.get_payment_buttons(@order_data)

    @xml_hash=Hash.from_xml(response.body)
    @banks={}
    return unless trade=@xml_hash["trade"]
    return unless payments=trade["payments"]
    return unless payment=payments["payment"]
    return unless banks=payment["banks"]
    @banks=banks unless banks.nil?    
  end

  # GET /payments/new
  def new
    @payment=Payment.new( amount: 1000, payer_data: {   
      'FIRSTNAME'     => 'Matti',
      'FAMILYNAME'    => 'Meikäläinen',
      'ADDRESS'       => "Ääkköstie 5 b 3\nGround floor",
      'POSTCODE'      => '33100',
      'POSTOFFICE'    => 'Tampere',
      'EMAIL'         => 'support@checkout.fi',
      'PHONE'         => '0800 552 010'
    })     
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(amount: 1000)
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

  def cancel
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
