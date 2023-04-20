class AddOkxColumnsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :okx_api_key, :string
    add_column :users, :okx_secret_key, :string
    add_column :users, :okx_passphrase, :string
  end
end
