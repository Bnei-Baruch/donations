require File.dirname(__FILE__) + '/../test_helper'
require 'admin_payment_controller'

# Re-raise errors caught by the controller.
class AdminPaymentController; def rescue_action(e) raise e end; end

class AdminPaymentControllerTest < Test::Unit::TestCase
  fixtures :payments

  def setup
    @controller = AdminPaymentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = payments(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:payments)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:payment)
    assert assigns(:payment).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:payment)
  end

  def test_create
    num_payments = Payment.count

    post :create, :payment => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_payments + 1, Payment.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:payment)
    assert assigns(:payment).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Payment.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Payment.find(@first_id)
    }
  end
end
