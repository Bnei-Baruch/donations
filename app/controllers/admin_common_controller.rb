class AdminCommonController < ApplicationController
  
  layout 'admin'
  
  before_filter :authorize

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @common_pages, @commons = paginate :commons, :per_page => 10
  end

  def show
    @common = Common.find(params[:id])
  end

  def new
    @common = Common.new
  end

  def create
    @common = Common.new(params[:common])
    if @common.save
      flash[:notice] = 'Common was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @common = Common.find(params[:id])
  end

  def update
    @common = Common.find(params[:id])
    if @common.update_attributes(params[:common])
      flash[:notice] = 'Common was successfully updated.'
      redirect_to :action => 'show', :id => @common
    else
      render :action => 'edit'
    end
  end

  def destroy
    Common.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
