class RegistrationController < Devise::RegistrationController

	protected

	def after_sign_up_path_for(resource)
		'/subcribers/new'
	end
	 
end