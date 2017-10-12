class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.text :payer_data
      t.string :reference 
      t.decimal :amount,  precision: 12, scale: 3
      t.integer :status, default: 0
      t.string :authorization_code

      t.timestamps
    end
  end
end
