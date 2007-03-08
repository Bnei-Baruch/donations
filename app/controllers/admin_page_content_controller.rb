class AdminPageContentController < ApplicationController

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
    @page_content_pages, @page_contents = paginate :page_contents, :per_page => 10
  end

  def show
    @page_content = PageContent.find(params[:id])
  end

  def new
    @page_content = PageContent.new
  end

  def create
    @page_content = PageContent.new(params[:page_content])
    if @page_content.save
      flash[:notice] = 'PageContent was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @page_content = PageContent.find(params[:id])
  end

  def update
    @page_content = PageContent.find(params[:id])
    if @page_content.update_attributes(params[:page_content])
      flash[:notice] = 'PageContent was successfully updated.'
      redirect_to :action => 'show', :id => @page_content
    else
      render :action => 'edit'
    end
  end

  def destroy
    PageContent.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
