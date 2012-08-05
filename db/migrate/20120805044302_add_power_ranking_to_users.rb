class AddPowerRankingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :power_ranking, :float
  end
end
