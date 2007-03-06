require File.dirname(__FILE__) + '/../test_helper'
require 'admin_donor_controller'

# Re-raise errors caught by the controller.
class AdminDonorController; def rescue_action(e) raise e end; end

class AdminDonorControllerTest < Test::Unit::TestCase
  fixtures :donors

  def setup
    @controller = AdminDonorController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = donors(:first).id
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

    assert_not_nil assigns(:donors)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:donor)
    assert assigns(:donor).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:donor)
  end

  def test_create
    num_donors = Donor.count

    post :create, :donor => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_donors + 1, Donor.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:donor)
    assert assigns(:donor).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Donor.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Donor.find(@first_id)
    }
  end
end
