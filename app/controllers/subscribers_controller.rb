class SubscribersController < ApplicationController
	
	before_filter :authenticate_user!

	def new

		@plans = Stripe::Plan.list.data.sort_by { |plan| plan['id'].to_i }

		@url = "http://logok.org/wp-content/uploads/2014/03/BMW-logo.png"

		if current_user.subscribed && current_user.stripe_id.present? && Stripe::Customer.retrieve(current_user.stripe_id).subscriptions.data.present?
			flash[:notice] = "You have already subscribed to our live charts."
			redirect_to chart_premium_path
		end

	end

	def create
		token = params[:stripeToken]

		if current_user.stripe_id.blank?

			customer = Stripe::Customer.create(
				card: token,
				plan: params[:plan].to_i,
				email: current_user.email
			)

		else
			sub = Stripe::Subscription.create(
				customer: current_user.stripe_id,
				plan: params[:plan].to_i
				)

		end





		current_user.subscribed = true
		if customer.present?
			current_user.stripe_id = customer.id
		end
		current_user.save
		flash[:success]= 'Congratulations! You have subscribed successfully to ETF Finance Live Chart.'

		redirect_to subscriber_path(current_user.stripe_id)
	end


	def show
		if current_user.subscribed && current_user.stripe_id.present? && Stripe::Customer.retrieve(current_user.stripe_id).subscriptions.data.present?
			@sub = Stripe::Customer.retrieve(current_user.stripe_id).subscriptions.data.first
		end
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
