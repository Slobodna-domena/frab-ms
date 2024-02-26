class AddSkippedToUserAdapter < ActiveRecord::Migration[5.1]
  def change
    add_column :user_adapters, :skipped, :integer, array: true, default: []
  end
end
