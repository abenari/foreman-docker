class AddKatelloFlagToContainers < ActiveRecord::Migration[4.2]
  def up
    add_column :containers, :katello, :boolean
  end

  def down
    remove_column :containers, :katello
  end
end
