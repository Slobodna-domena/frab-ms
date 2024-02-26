class AddCListToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :c_list, :string
    add_column :payments, :solidarity_fee, :boolean
  end
end
