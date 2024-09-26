class CreateExpenditureCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :expenditure_costs do |t|
      t.integer :category, null: false
      t.string :expenses_name, null: false
      t.integer :price, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
