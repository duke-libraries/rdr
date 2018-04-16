class AddUidToUsers < ActiveRecord::Migration[5.1]
  def change
    change_table :users do |t|
      t.string :uid, index: true
    end
  end
end
