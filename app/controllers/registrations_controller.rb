class RegistrationsController < Devise::RegistrationsController
  protected

  # def new
  # 	super
  # end


  def after_sign_up_path_for(resource)
    new_subscriber_path
  end
end


