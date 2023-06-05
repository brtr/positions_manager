class CreateUserPositionsNotesHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :user_positions_notes_histories do |t|
      t.references :user
      t.references :user_position
      t.text    :notes

      t.timestamps
    end
  end
end
