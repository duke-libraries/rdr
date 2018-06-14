class CreateBoxAccessTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :box_access_tokens do |t|
      t.string :token

      t.timestamps
    end
  end
end
