class AddAcceptedToUserAdapter < ActiveRecord::Migration[5.1]
  def change
    add_column :user_adapters, :accepted, :integer, array: true, default: []
  end
end
