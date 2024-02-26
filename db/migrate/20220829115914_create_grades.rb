class CreateGrades < ActiveRecord::Migration[5.1]
  def change
    create_table :grades do |t|
      t.integer :user_id
      t.integer :paper_id
      t.integer :value
      t.text :note

      t.timestamps
    end
  end
end
