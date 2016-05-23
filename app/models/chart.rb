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
			element = Chart.last.data.find{|x| x["value"]==nil }
			element["value"] = value
			start += symbols_array.size
			stop += symbols_array.size
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
    self.data = [{:time=>" 6:00 AM", :value=>0},
	 {:time=>" 6:10 AM", :value=>nil},
	 {:time=>" 6:20 AM", :value=>nil},
	 {:time=>" 6:30 AM", :value=>nil},
	 {:time=>" 6:40 AM", :value=>nil},
	 {:time=>" 6:50 AM", :value=>nil},
	 {:time=>" 7:00 AM", :value=>nil},
	 {:time=>" 7:10 AM", :value=>nil},
	 {:time=>" 7:20 AM", :value=>nil},
	 {:time=>" 7:30 AM", :value=>nil},
	 {:time=>" 7:40 AM", :value=>nil},
	 {:time=>" 7:50 AM", :value=>nil},
	 {:time=>" 8:00 AM", :value=>nil},
	 {:time=>" 8:10 AM", :value=>nil},
	 {:time=>" 8:20 AM", :value=>nil},
	 {:time=>" 8:30 AM", :value=>nil},
	 {:time=>" 8:40 AM", :value=>nil},
	 {:time=>" 8:50 AM", :value=>nil},
	 {:time=>" 9:00 AM", :value=>nil},
	 {:time=>" 9:10 AM", :value=>nil},
	 {:time=>" 9:20 AM", :value=>nil},
	 {:time=>" 9:30 AM", :value=>nil},
	 {:time=>" 9:40 AM", :value=>nil},
	 {:time=>" 9:50 AM", :value=>nil},
	 {:time=>"10:00 AM", :value=>nil},
	 {:time=>"10:10 AM", :value=>nil},
	 {:time=>"10:20 AM", :value=>nil},
	 {:time=>"10:30 AM", :value=>nil},
	 {:time=>"10:40 AM", :value=>nil},
	 {:time=>"10:50 AM", :value=>nil},
	 {:time=>"11:00 AM", :value=>nil},
	 {:time=>"11:10 AM", :value=>nil},
	 {:time=>"11:20 AM", :value=>nil},
	 {:time=>"11:30 AM", :value=>nil},
	 {:time=>"11:40 AM", :value=>nil},
	 {:time=>"11:50 AM", :value=>nil},
	 {:time=>"12:00 PM", :value=>nil},
	 {:time=>"12:10 PM", :value=>nil},
	 {:time=>"12:20 PM", :value=>nil},
	 {:time=>"12:30 PM", :value=>nil},
	 {:time=>"12:40 PM", :value=>nil},
	 {:time=>"12:50 PM", :value=>nil},
	 {:time=>" 1:00 PM", :value=>nil},
	 {:time=>" 1:10 PM", :value=>nil},
	 {:time=>" 1:20 PM", :value=>nil},
	 {:time=>" 1:30 PM", :value=>nil},
	 {:time=>" 1:40 PM", :value=>nil},
	 {:time=>" 1:50 PM", :value=>nil},
	 {:time=>" 2:00 PM", :value=>nil},
	 {:time=>" 2:10 PM", :value=>nil},
	 {:time=>" 2:20 PM", :value=>nil},
	 {:time=>" 2:30 PM", :value=>nil},
	 {:time=>" 2:40 PM", :value=>nil},
	 {:time=>" 2:50 PM", :value=>nil},
	 {:time=>" 3:00 PM", :value=>nil},
	 {:time=>" 3:10 PM", :value=>nil},
	 {:time=>" 3:20 PM", :value=>nil},
	 {:time=>" 3:30 PM", :value=>nil},
	 {:time=>" 3:40 PM", :value=>nil},
	 {:time=>" 3:50 PM", :value=>nil},
	 {:time=>" 4:00 PM", :value=>nil}]
  end
end
