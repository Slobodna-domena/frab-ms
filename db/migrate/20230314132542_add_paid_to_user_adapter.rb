class AddPaidToUserAdapter < ActiveRecord::Migration[5.1]
  def change
    add_column :user_adapters, :paid, :boolean
  end
end
