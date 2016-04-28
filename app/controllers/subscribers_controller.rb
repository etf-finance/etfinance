class SubscribersController < ApplicationController
	
	before_filter :authenticate_user!

	def new
		if !current_user.subscribed
			@amount = 2000
			@url = "http://logok.org/wp-content/uploads/2014/03/BMW-logo.png"
		else
			flash[:notice] = "You have already subscribed to our live charts."
			redirect_to chart_premium_path
		end
	end

	def create
		token = params[:stripeToken]

		customer = Stripe::Customer.create(
			card: token,
			plan: 1020,
			email: current_user.email
			)

		current_user.subscribed = true
		current_user.stripe_id = customer.id
		current_user.save
		flash[:success]= 'Congratulations! You have subscribed to ETF Finance Live Chart.'

		redirect_to chart_premium_path
	end

	def update
		token = params[:stripeToken]

		customer = Stripe::Customer.create(
			card: token,
			plan: 1020,
			email: current_user.email
			)

		current_user.subscribed = true
		cuurent_user.stripeid = customer.id
		current_user.save

		redirect_to root_path
	end
end
