module WelcomeHelper
	def subscribe_button
   	link_to "Subscribe now", new_subscriber_path, class: "btn btn-xl btn-danger",data: { no_turbolink: true }
  end

  def subscribe_text
  	if (current_user && !current_user.subscribed) || !current_user
  		return "Subscribe now"
  	else
  		return "View live performance"
  	end
  end

  def subscribe_path
  	if !current_user
  		return new_user_registration_path
  	elsif current_user && !current_user.subscribed
  		return new_subscriber_path
  	else
  		return chart_premium_path
  	end
  end

  def subscribe_class
  	if current_user && current_user.subscribed
  		return "btn-success"
  	else
  		return "btn-danger"
  	end
  end
end
