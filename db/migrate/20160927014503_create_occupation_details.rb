class CreateOccupationDetails < ActiveRecord::Migration

  def change
    create_table :occupation_details do |t|
      t.references :member
      t.string     :description

      t.timestamps null: false
    end
  end
end
