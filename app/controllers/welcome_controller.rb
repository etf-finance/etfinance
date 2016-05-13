class WelcomeController < ApplicationController
  def index
  	
  end

  def services
  end

  def newsletter_subscription
    if User.find_by_email(params[:email]).present?
      flash[:success]= 'Votre inscription à la newsletter ETF FINANCE est validée.'
    elsif params[:email][/\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/].nil?
      flash[:error]= 'Vous devez renseigner votre email pour vous inscrire à la newsletter.'
    else
      gibbon = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
      gibbon.lists(ENV['MAILCHIMP_LIST_ID']).members.create(body: {email_address: params[:email], status: "subscribed", merge_fields: {FNAME: "", LNAME: ""}})
      flash[:success]= 'Votre inscription à la newsletter ETF FINANCE est validée.'
    end

    redirect_to root_path

  end
end
