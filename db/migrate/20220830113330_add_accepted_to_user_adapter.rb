class AddAcceptedToUserAdapter < ActiveRecord::Migration[5.1]
  def change
    add_column :user_adapters, :accepted, :integer, array: true, default: [] unless column_exists?(:user_adapters, :accepted)
  end
end
