class ChangePlayerOneTwoToDefenderChallenger < ActiveRecord::Migration
  def change
    rename_column :matches, :user_one_score, :defender_score
    rename_column :matches, :user_two_score, :challenger_score
    rename_column :matches, :user_one_id,    :defender_id
    rename_column :matches, :user_two_id,    :challenger_id
  end
end
