class RemoveUserIdFromResults < ActiveRecord::Migration
  def change
    remove_column :results, :user_id, :integer
  end
end
