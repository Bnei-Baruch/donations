require File.dirname(__FILE__) + '/../test_helper'
require 'admin_page_content_controller'

# Re-raise errors caught by the controller.
class AdminPageContentController; def rescue_action(e) raise e end; end

class AdminPageContentControllerTest < Test::Unit::TestCase
  fixtures :page_contents

  def setup
    @controller = AdminPageContentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = page_contents(:first).id
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

    assert_not_nil assigns(:page_contents)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:page_content)
    assert assigns(:page_content).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:page_content)
  end

  def test_create
    num_page_contents = PageContent.count

    post :create, :page_content => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_page_contents + 1, PageContent.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:page_content)
    assert assigns(:page_content).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      PageContent.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      PageContent.find(@first_id)
    }
  end
end
