class CreatePapers < ActiveRecord::Migration[5.1]
  def change
    unless table_exists?(:papers)
      create_table :papers do |t|
        t.integer :event_id, null: false
        t.timestamps
      end
    end
  end
end
