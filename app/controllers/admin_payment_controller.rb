class AdminPaymentController < ApplicationController
  layout 'admin'
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @payment_pages, @payments = paginate :payments, :per_page => 10
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def new
    @payment = Payment.new
  end

  def create
    @payment = Payment.new(params[:payment])
    if @payment.save
      flash[:notice] = 'Payment was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def update
    @payment = Payment.find(params[:id])
    if @payment.update_attributes(params[:payment])
      flash[:notice] = 'Payment was successfully updated.'
      redirect_to :action => 'show', :id => @payment
    else
      render :action => 'edit'
    end
  end

  def destroy
    Payment.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
