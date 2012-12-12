class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.string :name
      t.integer :freq
      t.integer :category_id

      t.timestamps
    end
  end
end
