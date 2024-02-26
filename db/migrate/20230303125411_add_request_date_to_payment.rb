class AddRequestDateToPayment < ActiveRecord::Migration[5.1]
  def change
    add_column :payments, :request_date, :datetime
  end
end
