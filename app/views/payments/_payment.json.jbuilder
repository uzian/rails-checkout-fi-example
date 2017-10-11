json.extract! payment, :id, :first_name, :last_name, :last4, :amount, :success, :authorization_code, :created_at, :updated_at
json.url payment_url(payment, format: :json)
