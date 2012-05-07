class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :first_user_id
      t.integer :second_user_id
      t.integer :first_user_score
      t.integer :second_user_score
      t.date    :date_played

      t.timestamps
    end
    add_index :matches, :first_user_id
    add_index :matches, :second_user_id
  end
end
