class AddRefToProductEntry < ActiveRecord::Migration[7.0]
  def change
    add_reference :product_entries, :user, null: true, foreign_key: true
  end
end
