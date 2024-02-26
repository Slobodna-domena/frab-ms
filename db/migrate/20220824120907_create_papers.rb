class CreatePapers < ActiveRecord::Migration[5.1]
  def change
    create_table :papers do |t|
      t.integer :event_id, null: false
      t.timestamps
    end
  end
end
