class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  class NilShibbolethUserError < RuntimeError
    attr_accessor :auth

    def initialize(message = nil, auth = nil)
      super(message)
      self.auth = auth
    end
  end

  attr_accessible :email, :password, :password_confirmation if Blacklight::Utils.needs_attr_accessible?

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # remove :database_authenticatable in production, remove :validatable to integrate with Shibboleth
  devise_modules = [:omniauthable, :rememberable, :trackable, omniauth_providers: [:shibboleth], authentication_keys: [:uid]]
  devise_modules.prepend(:database_authenticatable) if AuthConfig.use_database_auth?
  devise(*devise_modules)

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  # When a user authenticates via shibboleth, find their User object or make
  # a new one. Populate it with data we get from shibboleth.
  # @param [OmniAuth::AuthHash] auth
  def self.from_omniauth(auth)
    raise User::NilShibbolethUserError.new("No uid", auth) if auth.uid.empty? || auth.info.uid.empty?
    user = find_by(provider: auth.provider, uid: auth.info.uid)
    raise User::NilShibbolethUserError.new("No user found", user) if user.nil?
    user.display_name = auth.info.display_name
    user.uid = auth.info.uid
    user.ppid = auth.uid
    user.save
    user
  rescue User::NilShibbolethUserError => e
    Rails.logger.error "Nil user detected: Shibboleth didn't pass a uid for #{e.auth.inspect}"
  end
end

# Override a Hyrax class that expects to create system users with passwords.
# Since in production we're using shibboleth, and this removes the password
# methods from the User model, we need to override it.
module Hyrax::User
  module ClassMethods
    def find_or_create_system_user(user_key)
      u = ::User.find_or_create_by(uid: user_key)
      u.display_name = user_key
      u.email = "#{user_key}@example.com"
      u.password = ('a'..'z').to_a.shuffle(random: Random.new).join if AuthConfig.use_database_auth?
      u.save
      u
    end
  end
end
