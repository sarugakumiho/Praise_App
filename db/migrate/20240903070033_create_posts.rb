class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.references :member, null: false, foreign_key: true
      t.string :title
      t.date :start_on
      t.date :end_on
      t.text :memo
      t.integer :situation_status
      t.integer :post_status

      t.timestamps
    end
  end
end
