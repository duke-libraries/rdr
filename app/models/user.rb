class User < ApplicationRecord

  include Hyrax::User
  include Hyrax::UserUsageStats

  CURATOR_GROUP = 'curator'

  INSTITUTION_PRINCIPAL_NAME_SCOPE = 'duke.edu'

  if Blacklight::Utils.needs_attr_accessible?
    attr_accessible :email, :password, :password_confirmation
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles



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

  after_create :add_curators_as_proxies

  class << self
    # @param auth [OmniAuth::AuthHash] authenticated user information.
    # @return [User] the authenticated user, possibly a newly created record.
    # @see {User::OmniauthCallbacksController#shibboleth}
    def from_omniauth(auth)
      find_or_initialize_by(uid: auth.uid).tap do |user|
        user.password = Devise.friendly_token if user.new_record?
        user.update!(email: auth.info.email, display_name: auth.info.name)
      end
    end

    # Override method from Hyrax::User::ClassMethods so that it properly creates system users,
    # given that we do not use 'email' for Hydra.config.user_key_field.
    def find_or_create_system_user(user_key)
      User.find_by_user_key(user_key) ||
          User.create!(Hydra.config.user_key_field => user_key,
                       email: user_key,
                       password: Devise.friendly_token[0, 20])
    end

    def curators

      if curator_group = Role.find_by(name: User::CURATOR_GROUP)
        curator_group.users.map(&:user_key)
      else
        []
      end

    end

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

  # For Duke users, returns the (unscoped) NetID
  # For non-Duke users, returns nil
  def netid
    username, scope = user_key.split('@')
    username if scope == INSTITUTION_PRINCIPAL_NAME_SCOPE
  end

  def add_curators_as_proxies
    unless [ User.audit_user_key, User.batch_user_key ].include?(self.user_key)
      curators = self.class.curators
      curators.each do |curator_key|
        ProxyService.add(user: self, proxy: curator_key)
      end
    end
  end

  def curator?
    roles.where(name: User::CURATOR_GROUP).exists?
  end

end
