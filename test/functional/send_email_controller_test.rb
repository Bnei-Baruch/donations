require File.dirname(__FILE__) + '/../test_helper'
require 'send_email_controller'

# Re-raise errors caught by the controller.
class SendEmailController; def rescue_action(e) raise e end; end

class SendEmailControllerTest < Test::Unit::TestCase
  def setup
    @controller = SendEmailController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
