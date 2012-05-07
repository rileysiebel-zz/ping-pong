class ChangeMatchColumnNamesAgain < ActiveRecord::Migration
  def change
    rename_column :matches, :player_one_score, :user_one_score
    rename_column :matches, :player_two_score, :user_two_score
    rename_column :matches, :player_one_id, :user_one_id
    rename_column :matches, :player_two_id, :user_two_id
  end
end
