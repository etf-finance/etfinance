class CoefficientsController < ApplicationController
	def new
		@expired_coefficients = Coefficient.where(expired: true).last(5)
		@new_coefficients = Coefficient.where(expired: false)
		@coefficient = Coefficient.new
	end

	def create
		# @coefficient = Coefficient.create(params[:coefficient])
		@coefficient = Coefficient.create(symbol: params[:coefficient][:symbol].upcase, value: params[:coefficient][:value].to_f)
		redirect_to new_coefficient_path
	end

	def destroy
		@coefficient = Coefficient.find(params[:id])
		@coefficient.destroy
		redirect_to new_coefficient_path
	end


end
