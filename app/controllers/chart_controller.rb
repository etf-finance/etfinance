class ChartController < ApplicationController
	require "google/api_client"
	require "google_drive"

  def basic
  	
  end

  def premium
    @future_bookings_count_array = [{date: Time.now, value: 10}, {date: (Time.now - 2.days), value: 20}]


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
