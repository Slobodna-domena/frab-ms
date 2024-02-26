class AddUserIdToUserAdapter < ActiveRecord::Migration[5.1]
  def change
    add_column :user_adapters, :user_id, :integer
  end
end
