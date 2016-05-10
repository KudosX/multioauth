class SocialAccount < ApplicationRecord
  AVAILABLE_PROVIDERS = %w(twitter facebook linkedin instagram)

  belongs_to :user
  validates :provider, presence: true, inclusion: { in: AVAILABLE_PROVIDERS }
  validates :uid, uniqueness: { scope: :provider }

  class << self
    def from_omniauth(auth, user)
      # We try to fetch social_account based on the passed provider and uid
      # If such social account cannot be found, we define (initialize) a new one
      # Please note that initialization means that we ONLY store it in memory - we do not save it to the
      # database yet
      social_account = find_or_initialize_by(provider: auth['provider'], uid: auth['uid'])
      unless social_account.user
        # if the social_account does not have any parent user
        # we check if the user was passed
        # if no user is set, we raise an error - it means that we simply don't have enough data about the user
        # if the user IS set, we store its id
        user.nil? ? raise(RecordNotFound) : social_account.user = user
      end
      # now just save any other data
      social_account.name = auth['info']['name']
      # save the social_account into the database
      social_account.save!
      # and return it as a result
      social_account
    end
  end
end