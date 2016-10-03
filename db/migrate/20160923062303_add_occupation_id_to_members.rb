class AddOccupationIdToMembers < ActiveRecord::Migration

  def change
    add_column :members, :occupation_id, :integer
  end
end
