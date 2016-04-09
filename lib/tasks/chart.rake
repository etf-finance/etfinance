namespace :chart do
  desc "Update quotes in google spreadsheet"
  task update_spreadsheet: :environment do
    # disable_active_record_logger
    yahoo_client = YahooFinance::Client.new
    data = yahoo_client.quotes(["AAPL", "FB"], [:ask, :bid, :last_trade_date])
    session = GoogleDrive.saved_session("config.json")
    # Changer la méthode de sélection du spreadsheet
    spreadsheet = session.files.first
    # Créer chaque jour un nouveau worksheet ?
    ws = spreadsheet.worksheet_by_title("Yahoo Quotes")
    if ws[10,1].blank?
      ws[10,1] = 1
    else
      ws[10,1] = ws[10,1].to_i+1
    end

    col = ws[10,1].to_i
    value_string = data[0].ask
    value_float = value_string.to_f
    calc_float = calculation(value_float)

    ws[1,col] = value_string.sub('.', ',')
    ws[2, col] = calc_float.to_s.sub('.', ',')
    ws[3, col] = "#{Time.now.hour}:#{Time.now.min}"
    ws.save
    ap ENV['CLIENT_ID']


    # unfinished_bookings = Booking.where(status: [ 'pending', 'booked', 'paid', 'ongoing', 'created' ])
    # unfinished_bookings.each do |booking|
    #   call_and_print_if_changed :update_status, booking
    # end

    puts "Done."
  end

  def calculation(value)
    return (rand*value) 
  end
end