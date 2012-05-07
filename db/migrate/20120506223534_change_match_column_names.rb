class ChangeMatchColumnNames < ActiveRecord::Migration
  def change
    rename_column :matches, :first_user_score, :player_one_score
    rename_column :matches, :second_user_score, :player_two_score
    rename_column :matches, :first_user_id, :player_one_id
    rename_column :matches, :second_user_id, :player_two_id
  end
end
