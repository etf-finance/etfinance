class WelcomeController < ApplicationController
  def index
  	@hash = User.group_by_day(:created_at).count
  	# @hash = Hash.new
  	# @hash[:test] = 2
  	# @hash[:test2] = 10
  end
end
