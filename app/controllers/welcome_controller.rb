class WelcomeController < ApplicationController
  def index
  	quotes = Quote.all
  	@quotes = Quote.pluck(:created_at, :value)
  	@quotes.each do |el|
  		el[1] = el[1].to_i
  		# el[0] = el[0].strftime("%H:%M:%S%z")
  	end
  	{20.day.ago => 5, 1368174456 => 4, "2013-05-07 00:00:00 UTC" => 7}
  	@hash = Hash.new
  	quotes.each do |q|
  		@hash[q.created_at.strftime("%H:%M")] = q.value.to_i
  	end
  	ap @hash
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
