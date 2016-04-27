class ChartController < ApplicationController
	require "google/api_client"
	require "google_drive"

  before_action :authenticate_user!
  # , :except => [:index]

  def basic
  	
  end

  def premium
      charts = Chart.all
      size = charts.size
      chart_not_premium = charts[size-5]
    if !current_user.subscribed
      @date = Time.now - 4.days
      data = chart_not_premium.data
      @future_bookings_count_array = data
    else
      @date = Time.now
      @future_bookings_count_array = Chart.last.data
    end


  	# quotes = Quote.all
  	# @quotes = Quote.pluck(:created_at, :value)
  	# @quotes.each do |el|
  	# 	el[1] = el[1].to_i
  	# 	# el[0] = el[0].strftime("%H:%M:%S%z")
  	# end
  	# {20.day.ago => 5, 1368174456 => 4, "2013-05-07 00:00:00 UTC" => 7}
  	# @hash = Hash.new
  	# quotes.each do |q|
  	# 	@hash[q.created_at.strftime("%H:%M")] = q.value.to_i
  	# end
  	# ap @hash
  end
end
