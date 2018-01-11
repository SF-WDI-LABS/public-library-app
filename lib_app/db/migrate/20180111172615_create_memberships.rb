class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :library, foreign_key: true

      t.timestamps
    end
  end
end
