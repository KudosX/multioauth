class User < ApplicationRecord
  has_secure_password

  has_many :social_accounts, dependent: :destroy
  validates :email, presence: true, uniqueness: true

  def has_provider?(provider)
    !with_provider(provider).nil?
  end

  # Fetch user's social account by provider's name
  def with_provider(provider)
    social_accounts.find_by(provider: provider)
  end

  # def method_missing(name, *args, &block)
  #   provider = name.match(/has_(\w+)\?\z/)
  #   if provider && SocialAccount::AVAILABLE_PROVIDERS.include?(provider[1])
  #     social_accounts.where(provider: provider).any?
  #   else
  #     super
  #   end
  # end
end
