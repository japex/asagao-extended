class CreateOccupations < ActiveRecord::Migration

  def change
    create_table :occupations do |t|
      t.string :category, null: false

      t.timestamps null: false
    end
  end
end
