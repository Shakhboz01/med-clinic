class AddUnitToPacks < ActiveRecord::Migration[7.0]
  def change
    add_column :packs, :unit, :integer
  end
end
