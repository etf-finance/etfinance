class Chart < ActiveRecord::Base
	after_create :default_values



	def recreate
		self.default_values

		self.save

		date = self.created_at.to_date

		symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]

		quotes = Quote.where(symbol: symbols_array).where('created_at < ?', date + 1.days).where('created_at > ?', date)

		number_of_moments = quotes.size / symbols_array.size

		start = 0
		stop = symbols_array.size-1

		for n in (1..number_of_moments)
			batch = quotes[start..stop]
			value = global_perf(batch).round(2)
			element = self.data.find{|x| x["value"]==nil }
			element["value"] = value
			start += symbols_array.size
			stop += symbols_array.size
		end

		self.save


	end


	def redesign
		self.default_values

		date = self.created_at.to_date

		symbols_array = ["SPY", "VXX", "VXZ", "XIV", "ZIV"]

		quotes = Quote.where(symbol: symbols_array).where('created_at < ?', date + 1.days).where('created_at > ?', date)

		index = 0

		while index < quotes.size
			array = []
			quote = quotes[index]
			array = [quote]
			time = quote.round_time

			index += 1
			quote = quotes[index]

			while quote.present? && quote.round_time == time
				array << quote
				index += 1
				quote = quotes[index]
			end

			value = global_perf(array).round(2)
			element = self.data.find{|x| x["value"]==nil }
			element["value"] = value
			# element["time"] = time

		end

		self.save
	end


	






	protected

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




  def default_values
    data = []
    date = self.created_at.to_date
    time = Time.new(date.year, date.month, date.day, 6, 0, 0)
    data << {time: time, value: 0}
    while time <= Time.new(date.year, date.month, date.day, 16, 0, 0)
    	time += 10.minutes
    	data << {time: time, value: nil}
    end
    self.data = data
    self.save
  end
end
