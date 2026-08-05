class AddCListToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :c_list, :string unless column_exists?(:payments, :c_list)
    add_column :payments, :solidarity_fee, :boolean unless column_exists?(:payments, :solidarity_fee)
  end
end
