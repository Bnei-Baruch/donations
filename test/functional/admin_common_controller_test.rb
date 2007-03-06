require File.dirname(__FILE__) + '/../test_helper'
require 'admin_common_controller'

# Re-raise errors caught by the controller.
class AdminCommonController; def rescue_action(e) raise e end; end

class AdminCommonControllerTest < Test::Unit::TestCase
  def setup
    @controller = AdminCommonController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
