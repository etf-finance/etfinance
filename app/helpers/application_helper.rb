module ApplicationHelper
	# =============== LOGIQUE FLASH ============
  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "text-center alert #{bootstrap_class_for(msg_type)} flash-message fade in") do
        concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
        concat message
      end)
    end
    nil
  end
  # ======================

  def test
    puts "test done !!!!"
  end


  def market_moment(opening_time, closing_time)
    if Time.now.utc > opening_time && Time.now.utc < closing_time - 5.minutes
      return "open"
    elsif Time.now.utc >= closing_time - 5.minutes && Time.now.utc < closing_time
      return "before_closing"
    else
      return "close"
    end
  end

end
