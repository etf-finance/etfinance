class SubscribersController < ApplicationController
	
	before_filter :authenticate_user!

	def new
		@amount = 2000
	end

	def create
		raise
	end

	def update
		raise
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
