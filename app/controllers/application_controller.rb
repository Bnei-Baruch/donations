class ApplicationController < ActionController::Base
  filter_parameters_logging "password", "ccno", "mycvv", "myid", "sum"
end

