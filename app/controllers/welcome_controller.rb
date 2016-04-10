class WelcomeController < ApplicationController
  def index
  	@quotes = Quote.pluck(:created_at, :value)
  	@quotes.each do |el|
  		el[1] = el[1].to_i
  		# el[0] = el[0].strftime("%H:%M:%S%z")
  	end
  end
end
