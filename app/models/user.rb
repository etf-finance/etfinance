class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :session_limitable

  after_create :add_to_mailchimp

  def add_to_mailchimp
    gibbon = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])

    begin
      gibbon.lists(ENV['MAILCHIMP_LIST_ID']).members.create(body: {email_address: email, status: "subscribed", merge_fields: {FNAME: first_name, LNAME: last_name}})
    rescue
    end
  end


  def subscriber?
    if self.stripe_id.nil?
      return false
    else
      customer = Stripe::Customer.retrieve(self.stripe_id)
      if customer.subscriptions.data.blank? || !self.subscribed
        return false
      else
        return true
      end
    end
  end

end
