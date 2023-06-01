class AddNotesToUserPositions < ActiveRecord::Migration[6.1]
  def change
    add_column :user_positions, :notes, :text
  end
end
