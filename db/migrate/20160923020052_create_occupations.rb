class CreateOccupations < ActiveRecord::Migration

  def change
    create_table :occupations do |t|
      t.string  :category         , null: false
      t.boolean :needs_description, null: false, default: false
      t.integer :display_order    , null: false

      t.timestamps null: false
    end
  end
end
