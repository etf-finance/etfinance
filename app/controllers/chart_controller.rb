class ChartController < ApplicationController
	require "google/api_client"
	require "google_drive"

  before_action :authenticate_user!
  # , :except => [:index]

  def basic
  	
  end

  def sections
    @futures_class = "active"
    @perf_class = "inactive"

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

    @perf_class = "active"
    @futures_class = "inactive"

    yahoo_client = YahooFinance::Client.new
    
    @symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]

    yahoo_data = yahoo_client.quotes(@symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close])

    @table_array = []

    @symbols_array.each do |symbol|
      today_coef = Coefficient.where(symbol: symbol).where(expired: true).last.value 
      if market_moment == "open"
        @new_coef_class = "expired"
        tomorrow_coef = today_coef
      else
        @new_coef_class = "recent"
        tomorrow_coef = Coefficient.where(symbol: symbol).last.value
      end


      if Quote.where(symbol: symbol).blank?
        data = yahoo_client.quotes([symbol], [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close])
        os_to_db(data[0])
      end

      previous_close = Quote.where(symbol: symbol).last.previous_close

      nbr_shares_today = ((today_coef/previous_close)*10000) 
      nbr_shares_tomorrow = ((tomorrow_coef/previous_close)*10000) 
      delta = nbr_shares_tomorrow -  nbr_shares_today

      obj = {
        symbol: symbol,
        today_coef: today_coef,
        tomorrow_coef: tomorrow_coef, 
        previous_close: previous_close,
        nbr_shares_today: nbr_shares_today, 
        nbr_shares_tomorrow: nbr_shares_tomorrow, 
        delta: delta 
      }
      @table_array << obj
    end



    # if market_moment != 'before_closing'
    #   @new_coef_class = "before-closing"
    # end

    yahoo_client = YahooFinance::Client.new
    yahoo_data = yahoo_client.quotes(@symbols_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name])
    
    charts = Chart.all
    size = charts.size
    chart_not_premium = charts[size-5]

    
    if current_user.stripe_id.nil?
      redirect_to new_subscriber_path
    else
      customer = Stripe::Customer.retrieve(current_user.stripe_id)

      if customer.subscriptions.data.blank? || !current_user.subscribed
        redirect_to new_subscriber_path
        # @date = Time.now - 4.days
        # data = chart_not_premium.data
        # @chart_data = data
      else
        @date = Time.now
        @chart_data= Chart.last.data
      end
    end
  end


  def new_coef
    
  end


  private


  def market_moment
    opening_hour = 5
    closing_hour = 13
    if Time.now.hour > opening_hour && Time.now.hour < closing_hour && (Time.now.hour == closing_hour-1 && Time.now.min < 50)
      return "open"
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


  def yahoo_to_db(array)
    array.each do |el|
      Quote.create(symbol: el.symbol, bid: el.bid.to_f, ask: el.ask.to_f, close: el.close.to_f, previous_close: el.previous_close.to_f)
    end
  end

  def os_to_db(object)
    quote = Quote.create(symbol: object.symbol, bid: object.bid.to_f, ask: object.ask.to_f, close: object.close.to_f, previous_close: object.previous_close.to_f)
    return quote
  end










end
