class AddSkippedToUserAdapter < ActiveRecord::Migration[5.1]
  def change
    add_column :user_adapters, :skipped, :integer, array: true, default: [] unless column_exists?(:user_adapters, :skipped)
  end
end
