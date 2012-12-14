class CreateServicos < ActiveRecord::Migration
  def change
    create_table :servicos do |t|
      t.string  :nome
      t.integer :local_id

      t.timestamps
    end
  end
end
