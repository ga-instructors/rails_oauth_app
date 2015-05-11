class User < ActiveRecord::Base
  validates :email, :oauth_uid, presence: true, uniqueness: true
  validates :name,  presence: true
end
