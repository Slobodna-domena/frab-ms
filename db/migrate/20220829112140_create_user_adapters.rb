class CreateUserAdapters < ActiveRecord::Migration[5.1]
  def change
    create_table :user_adapters do |t|
      t.integer :number_of_papers_evaluated, null: false, default: 0
      t.integer :papers_evaluated, null: false,array: true, default: []
      t.timestamps
    end
  end
end
