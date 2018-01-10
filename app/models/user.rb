class User < ApplicationRecord

  include Hyrax::User
  include Hyrax::UserUsageStats

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :omniauthable,
         :registerable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         omniauth_providers: [:shibboleth]

  validates :uid, presence: true, uniqueness: true

  # @param auth [OmniAuth::AuthHash] authenticated user information.
  # @return [User] the authenticated user, possibly a newly created record.
  # @see {User::OmniauthCallbacksController#shibboleth}
  def self.from_omniauth(auth)
    find_or_initialize_by(uid: auth.uid).tap do |user|
      user.password = Devise.friendly_token if user.new_record?
      user.update!(email: auth.info.email, display_name: auth.info.name)
    end
  end

  # Override method from Hyrax::User::ClassMethods so that it properly creates system users,
  # given that we do not use 'email' for Hydra.config.user_key_field.
  def self.find_or_create_system_user(user_key)
    User.find_by_user_key(user_key) ||
        User.create!(Hydra.config.user_key_field => user_key,
                     email: user_key,
                     password: Devise.friendly_token[0, 20])
  end

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    display_name || uid
  end

  def user_key
    uid
  end
end
