class ChartController < ApplicationController
	require "google/api_client"
	require "google_drive"

  before_action :authenticate_user!
  # , :except => [:index]

  def basic
  	
  end

  def futures
    sections_array = []
    xLabels = []

  end

  def premium
    yahoo_client = YahooFinance::Client.new

    sections_array = ["^VIXMAY", "^VIXJUN", "^VIXJUL", "^VIXAUG"]
    xLabels = []

    data = yahoo_client.quotes(sections_array, [:ask, :bid, :last_trade_date, :last_trade_price, :symbol, :name])

    # array.each_with_index {|val, index| puts "#{val} => #{index}" }

    @futures = []

    data.each_with_index do |el|
      if el.ask.to_f == 0 && el.bid.to_f == 0
        value = el.last_trade_price.to_f
      else
        value = (el.bid.to_f + el.ask.to_f)/2
      end
      obj = {symbol: el.symbol, value: value, date: el.symbol.last(3).capitalize}
      @futures << obj
    end






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

  end
end
