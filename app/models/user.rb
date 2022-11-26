class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_positions, dependent: :destroy
  has_many :user_synced_positions, dependent: :destroy
  has_many :snapshot_infos, dependent: :destroy
  has_many :snapshot_positions, through: :snapshot_infos
end
