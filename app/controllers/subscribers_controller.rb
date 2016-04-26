class SubscribersController < ApplicationController
	
	before_filter :authenticate_user!

	def new
		@amount = 2000
		@url = "http://logok.org/wp-content/uploads/2014/03/BMW-logo.png"
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

		redirect_to root_path
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
