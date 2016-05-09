class CreateSocialAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :social_accounts do |t|
      t.references :user, foreign_key: true
      t.integer :user_id
      t.string :name
      t.string :provider, index: true
      t.string :uid, index: true
      t.string :location
      t.string :image_url
      t.string :url

      t.timestamps null: false
    end

    add_index :social_accounts, [:provider, :uid], unique: true
  end
end
