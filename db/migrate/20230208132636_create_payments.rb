class CreatePayments < ActiveRecord::Migration[5.1]
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.string :country
      t.boolean :status
      t.string :document
      t.string :billing_name
      t.string :billing_address
      t.string :billing_vat
      t.integer :payment_status

      t.timestamps
    end
  end
end
