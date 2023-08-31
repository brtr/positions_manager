class WalletHistory < ApplicationRecord
  belongs_to :user, optional: true

  enum trade_type: [:deposit, :withdraw]
  enum transfer_type: [:external, :internal]
end
