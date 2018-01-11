class CreateLibraries < ActiveRecord::Migration[5.0]
  def change
    create_table :libraries do |t|
      t.text :name
      t.integer :floor_count

      t.timestamps
    end
  end
end
