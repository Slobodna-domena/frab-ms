class AddCounterToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :counter, :integer unless column_exists?(:users, :counter)
  end
end
