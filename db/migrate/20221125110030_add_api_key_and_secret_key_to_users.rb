class AddApiKeyAndSecretKeyToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :api_key, :string
    add_column :users, :secret_key, :string
  end
end
