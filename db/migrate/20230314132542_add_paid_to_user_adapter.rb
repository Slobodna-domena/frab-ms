class AddPaidToUserAdapter < ActiveRecord::Migration[5.1]
  def change
    add_column :user_adapters, :paid, :boolean unless column_exists?(:user_adapters, :paid)
  end
end
