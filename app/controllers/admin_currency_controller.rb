class AdminCurrencyController < ApplicationController
	layout 'admin'
	before_filter :authorize
	scaffold :currency
end
