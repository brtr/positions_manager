class AddLevelToUserPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :user_positions, :level, :integer
  end
end
