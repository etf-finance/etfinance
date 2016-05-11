class ChartController < ApplicationController
	require "google/api_client"
	require "google_drive"

  before_action :authenticate_user!
  # , :except => [:index]

  def basic
  	
  end

  def sections
    yahoo_client = YahooFinance::Client.new

    @sections_array = ["^VIXMAY", "^VIXJUN", "^VIXJUL", "^VIXAUG", "^VIXSEP", "^VIXOCT", "^VIXNOV"]# array de test qui pourra être actualisé 



    data = yahoo_client.quotes(@sections_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name])

    
    # @sections_array.each do |el|
    #   Coefficient.create(symbol: el, value: 1+rand)
    # end

    # Construction de l'array servant aux graph des futures
    @futures = []

    date = Time.now

    data.each_with_index do |el|
      if el.ask.to_f == 0 && el.bid.to_f == 0
        value = el.last_trade_price.to_f
      else
        value = (el.bid.to_f + el.ask.to_f)/2
      end
      obj = {symbol: el.symbol, value: value, date: date}
      @futures << obj
      dif = 21 - date.day
      if dif > 0
        date += dif.days
      else
        date += 1.months
      end
    end
  end



  def premium
    @symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]

    @today_coefficients = []
    @tomorrow_coefficients = []

    # @symbols_array.each do |symbol|
    #   Coefficient.where(symbol: symbol).last
    #   Coefficient.where('symbol = ? AND created_at < ?', "ZIV", Time.now-10.hours)

    # if market_moment == "opened"
    #   @number_of_days = 1
    # else
    #   @number_of_days = 2
    # end



    if market_moment != 'before_closing'
      @new_coef_class = "before-closing"
    end

    yahoo_client = YahooFinance::Client.new
    yahoo_data = yahoo_client.quotes(@symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name])
    
    charts = Chart.all
    size = charts.size
    chart_not_premium = charts[size-5]

    if !current_user.subscribed
      @date = Time.now - 4.days
      data = chart_not_premium.data
      @chart_data = data
    else
      @date = Time.now
      @chart_data= Chart.last.data
    end
  end

  private


  def market_moment
    if Time.now.hour > 5 && (Time.now.hour < 16 || (Time.now.hour == 15 && Time.now.min < 55))
      return "opened"
    elsif (Time.now.hour == 15 && Time.now.min > 54)
      return "before_closing"
    else
      return "close"
    end
  end

  def global_perf(array)
    perf = 0
    array.each do |el|
      perf += perf(el)
    end
    return perf
  end

  def perf(x)
    coef(x)*diff(x)
  end

  def diff(x)
    ((x.bid.to_f + x.ask.to_f)/2) - x.close.to_f
  end


  def coef(x)
    Coefficient.where(symbol: x.symbol).last.value
  end










end
