class ChartController < ApplicationController
	# require "google/api_client"
	# require "google_drive"

  @@opening_time = Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 9, 30, 0)

  @@closing_time = Time.zone.local(Time.zone.now.year, Time.zone.now.month, Time.zone.now.day, 16, 0, 0)


  before_action :authenticate_user!



  def sections

    yahoo_client = YahooFinance::Client.new

    future_month_names = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec', 'jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

    month_number = Time.now.month

    symbols =  ["^VIX" + future_month_names[month_number - 1].upcase, "^VIX" + future_month_names[month_number].upcase]

    data = yahoo_client.quotes([symbols])

    vix = yahoo_client.quotes(["^VIX"]).first.last_trade_price.to_f

    if data[0].last_trade_date == data[1].last_trade_date
      @i = month_number
    else
      @i = month_number + 1
    end

    sections_array = []
    for n in (@i..@i+6)
      sections_array << '^VIX' + future_month_names[n - 1].upcase
    end

    date = Time.now.to_date

    dif = 17 - date.day

    date_array = [date]

    if data[0].last_trade_date == data[1].last_trade_date
      date_array << date + dif.days
    else
      date_array << date + dif.days + 1.months
    end

    for n in (2..sections_array.size-1)
      date_array << date_array.last + 1.months
    end

    @date_array = date_array

    @sections_array = sections_array

    @yahoo_charts = sections_array + ['^GSPC','^VIX']

    @vix = vix





    
    @futures_class = "active active-btn"
    @perf_class = "inactive"


    # @sections_array = ["^VIXMAY", "^VIXJUN", "^VIXJUL", "^VIXAUG", "^VIXSEP", "^VIXOCT", "^VIXNOV"]# array de test qui pourra être actualisé 

    

    data = yahoo_client.quotes(@sections_array, [:ask, :bid, :last_trade_date, :last_trade_price, :close, :symbol, :name, :previous_close])
    

    @futures = []

    data.each_with_index do |el, i|
      if el.ask.to_f == 0 && el.bid.to_f == 0
        value = el.last_trade_price.to_f
      else
        value = (el.bid.to_f + el.ask.to_f)/2
      end
      previous_close = el.previous_close.to_f
      close = el.close.to_f
      obj = {symbol: el.symbol, value: value, date: @date_array[i], vix: vix, previous_close: previous_close, close: close }
      @futures << obj
    end


  end



  def premium

    # raise

    

    @refreshing_time = @@closing_time.localtime - 5.minutes

    @symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]

    days = params[:days].to_i || 0

    @perf_class = "active active-btn"
    @futures_class = "inactive"

    last_quote_date = Quote.last.created_at.to_date

    if current_user.subscriber?
      date = last_quote_date - days.days
      @premium = true
    else
      date = Date.today - 5.days
      @premium = false
    end


    quotes = []


    while quotes.size == 0
      quotes = Quote.where('created_at < ?', date + 1.days).where('created_at > ?', date).order('round_time ASC').where.not(last_trade_time: ["4:00pm", "3:59pm"]).to_a
      if quotes.size == 0
        days += 1
      end
    end

    @date = date

    quotes_batched = quotes.batching

    @chart_data = Array.new

    quotes_batched.each do |array|
      if @chart_data.blank?
        round_time = nil
      else
        round_time = @chart_data.last["round_time"]
      end
      @chart_data << array.batch_to_data
      if round_time == @chart_data.last["round_time"]
        @chart_data = @chart_data[0...-1]
      end
    end

    string = date.strftime("%m/%d/%Y")
    string_time = string + " 4:00pm"
    closing_time = DateTime.strptime(string_time, "%m/%d/%Y %l:%M%P")

    @chart_data << {round_time: closing_time, time: closing_time}



    if current_user.subscriber?

      @market_moment = "open"

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


  end



  def all_quotes

    @symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]

    days = params[:days].to_i || 0

    quotes = []

    while quotes.size == 0
      date = Date.today - days.days
      quotes = Quote.where(source: "yahoo_finance_gem").where('created_at < ?', date + 1.days).where('created_at > ?', date).order('round_time ASC').where.not(last_trade_time: ["4:00pm", "3:59pm"]).to_a
      if quotes.size == 0
        days += 1
      end
    end

    quotes_batched = quotes.batching

    @chart_data = Array.new

    quotes_batched.each do |array|
      if @chart_data.blank?
        round_time = nil
      else
        round_time = @chart_data.last["round_time"]
      end
      @chart_data << array.batch_to_data
      if round_time == @chart_data.last["round_time"]
        @chart_data = @chart_data[0...-1]
      end
    end

    string = date.strftime("%m/%d/%Y")
    string_time = string + " 4:00pm"
    closing_time = DateTime.strptime(string_time, "%m/%d/%Y %l:%M%P")

    @chart_data << {round_time: closing_time, time: closing_time}



    @symbols_array.each do |symbol|
      instance_variable_set("@"+symbol.downcase+"_array", symbol_to_ask_graph(symbol, date))
    end


    # @symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV", "AAPL"]

    @refreshing_time = @@closing_time.localtime - 5.minutes

    @perf_class = "active active-btn"
    @futures_class = "inactive"


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


  private

  def perf_data(array)

  end




  def market_moment(opening_time, closing_time)
    Time.zone = "America/New_York"
    if Time.zone.now.strftime("%A") == "Sunday" || Time.zone.now.strftime("%A") == "Saturday"
      return "close"
    elsif Time.zone.now > opening_time && Time.zone.now < closing_time - 5.minutes
      return "open"
    elsif Time.zone.now >= closing_time - 5.minutes && Time.now.utc < closing_time
      return "before_closing"
    else
      return "close"
    end
  end
  

  # def global_perf(array)
  #   perf = 0
  #   array.each do |el|
  #     perf += perf(el)
  #   end
  #   return perf
  # end

  # def perf(x)
  #   coef(x)*diff(x)
  # end

  # def diff(x)
  #   ((x.bid.to_f + x.ask.to_f)/2) - x.close.to_f
  # end


  # def coef(x)
  #   Coefficient.where(symbol: x.symbol).last.value
  # end


  # def yahoo_to_db(array)
  #   array.each do |el|
  #     Quote.create(symbol: el.symbol, bid: el.bid.to_f, ask: el.ask.to_f, close: el.close.to_f, previous_close: el.previous_close.to_f)
  #   end
  # end

  # def os_to_db(object)
  #   quote = Quote.create(symbol: object.symbol, bid: object.bid.to_f, ask: object.ask.to_f, close: object.close.to_f, previous_close: object.previous_close.to_f)
  #   return quote
  # end

  def symbol_to_ask_graph(symbol, date)

    quotes = Quote.where(symbol: symbol).where('created_at < ?', date + 1.days).where('created_at > ?', date).order('round_time ASC').where(source: "yahoo_finance_gem")

    hash = quotes.group_by { |i| i.round_time}

    array = hash.values.flatten

    array_for_graph = []

    array.each do |quote|
      unless quote.last_trade_time == "4:00pm" || quote.last_trade_time == "3:59pm"
        h = {}
        h["time"] = quote.round_time
        h["ask"] = quote.ask
        h["bid"] = quote.bid
        h["previous_close"] = quote.previous_close
        h["last_trade_time"] = quote.last_trade_time
        h["created_at"] = quote.created_at.strftime("%l:%M %p")
        array_for_graph << h
      end
    end
    return array_for_graph
  end



end






