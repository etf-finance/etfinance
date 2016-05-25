class ChartController < ApplicationController
	# require "google/api_client"
	# require "google_drive"

  @@opening_time = Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 6, 0, 0)

  @@closing_time = Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 16, 0, 0)


  before_action :authenticate_user!



  def sections

    yahoo_client = YahooFinance::Client.new

    future_month_names = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec', 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

    month_number = Time.now.month

    symbols =  ["^VIX" + future_month_names[month_number - 1].upcase, "^VIX" + future_month_names[month_number].upcase]

    data = yahoo_client.quotes(symbols)

    if data[0].last_trade_date == data[1].last_trade_date
      @i = month_number
    else
      @i = month_number + 1
    end

    @sections_array = []
    for n in (@i..@i+6)
      @sections_array << '^VIX' + future_month_names[n - 1].upcase
    end

    date = Time.now.to_date

    dif = 17 - date.day

    @date_array = [date]

    if data[0].last_trade_date == data[1].last_trade_date
      @date_array << date + dif.days
    else
      @date_array << date + dif.days + 1.months
    end

    for n in (2..@sections_array.size-1)
      @date_array << @date_array.last + 1.months
    end






    
    @futures_class = "active active-btn"
    @perf_class = "inactive"


    # @sections_array = ["^VIXMAY", "^VIXJUN", "^VIXJUL", "^VIXAUG", "^VIXSEP", "^VIXOCT", "^VIXNOV"]# array de test qui pourra être actualisé 

    

    data = yahoo_client.quotes(@sections_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name])

    
    # @sections_array.each do |el|
    #   Coefficient.create(symbol: el, value: 1+rand)
    # end

    # Construction de l'array servant aux graph des futures
    @futures = []



  

    data.each_with_index do |el, i|
      if el.ask.to_f == 0 && el.bid.to_f == 0
        value = el.last_trade_price.to_f
      else
        value = (el.bid.to_f + el.ask.to_f)/2
      end
      obj = {symbol: el.symbol, value: value, date: @date_array[i]}
      @futures << obj
    end


    # data.each_with_index do |el|
    #   if el.ask.to_f == 0 && el.bid.to_f == 0
    #     value = el.last_trade_price.to_f
    #   else
    #     value = (el.bid.to_f + el.ask.to_f)/2
    #   end
    #   obj = {symbol: el.symbol, value: value, date: date}
    #   @futures << obj
    #   dif = 21 - date.day
    #   if dif > 0
    #     date += dif.days
    #   else
    #     date += 1.months
    #   end
    # end

  end



  def premium



    @symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]

    @refreshing_time = @@closing_time.localtime - 5.minutes

    @perf_class = "active active-btn"
    @futures_class = "inactive"

    if current_user.subscriber?

      @chart = Chart.last

      @premium = true

      @market_moment = market_moment(@@opening_time, @@closing_time)


      @table_array = []

      @symbols_array.each do |symbol|
        today_coef = Coefficient.where(symbol: symbol).where(expired: true).last.value 
        if @market_moment == "open"
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
          delta: delta.round.to_i
        }
        @table_array << obj
      end
    end

    if !current_user.subscriber?
      @premium = false
      @chart = Chart.last(4).first
    end

    @chart_data = @chart.data



      # ==============  CREATION DU ARRAY POUR LE GRAPHIQUE DES QUOTES =============

    if current_user.admin?

      hash = {}

      quotes = Quote.where(symbol: @symbols_array).where('created_at > ?', @chart.created_at.to_date)
      
      quotes.each do |quote|
        if hash[(quote.symbol.downcase+"_ask")].blank?
          hash[(quote.symbol.downcase+"_ask")] = [quote.ask]
          hash[(quote.symbol.downcase+"_bid")] = [quote.bid]
        else
          hash[(quote.symbol.downcase+"_ask")] << quote.ask
          hash[(quote.symbol.downcase+"_bid")] << quote.bid
        end
      end

      @quotes_hash = hash

    end



    # ==============  CREATION DU ARRAY POUR LE GRAPHIQUE DES QUOTES ============= 


  end



  def basic

    @symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]

    charts = Chart.all
    size = charts.size
    # chart = charts[size-5]
    chart = Chart.last
    @date = Time.now - 4.days
    @chart_data= chart.data


    @table_array = []

    @symbols_array.each do |symbol|

      today_coef = Coefficient.where(symbol: symbol).last(2).first.value 
      @new_coef_class = "recent"
      tomorrow_coef = Coefficient.where(symbol: symbol).last(1).first.value

      previous_close = Quote.where(symbol: symbol).last(1).first.previous_close

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
        delta: delta.round.to_i
      }
      @table_array << obj
    end



  end


  def new_coef
    
  end


  private




  def market_moment(opening_time, closing_time)
    Time.zone = "America/New_York"
    if Time.zone.now > opening_time && Time.zone.now < closing_time - 5.minutes
      return "open"
    elsif Time.zone.now >= closing_time - 5.minutes && Time.now.utc < closing_time
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
