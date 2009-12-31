require 'cgi'

require 'socket'
require 'openssl'
require 'net/http'
require 'uri'
require 'finance/currency'
require 'curl'

class UserController < ApplicationController

  layout 'user'

  #before_filter :set_params

  def main
	set_params
  end

  def index
	set_params
  end

  def about
	 set_params
  end

  def why_now	
	 set_params
  end

  def faq
	 set_params
  end

  def privacy_and_security
	 set_params
  end

  def contact_us
	 set_params false	
  end

  def donors_list
	 set_params false

	 @items_per_page = 10
	 if params['page'] == "-1"
		 @items_per_page = 10000000
	 end
	 sort = case params['sort']
           when "date"					: "created_at"
           when "name"					: "name"
           when "country"				: "country"
           when "sum"					: "sum_dollars"
           when "date_reverse"		: "created_at DESC"
           when "name_reverse"		: "name DESC"
           when "country_reverse"	: "country DESC"
           when "sum_reverse" 		: "sum_dollars DESC"

			  else    "created_at DESC"
           end

    @donors_pages, @donors = paginate :donors,
									  :conditions => [ "approved = ? OR acked = ?", true, true ],
									  :per_page => @items_per_page,
									  :order => sort
	 @donors.each do |d|
		 d.name = _('Anonymous') if d.is_anonymous
		 d.country = "" if d.country == "Unknown" || d.country == "."
		 d.message = " " if d.message.empty?
	 end

	 if request.xhr?
		 render :partial => "donors_list", :layout => false
	 end
  end

  def projects_and_expenses
	 set_params false
    @projects = Project.all_completed_projects(@lang, false, false)
  end

  def window_privacy_and_security
	 set_params false
	 render :layout => 'layouts/main_full',
		 :text => "<h3>#{@page_title}</h3>#{@page_content}"
  end

  def bank_details
	get_language
    bank_details = Payment.bank_details(@lang)
	render :layout => 'layouts/main_full', :text => bank_details.description
  end

	
  def paypal
    	set_params false
	
	if params[:language] && @lang != params[:language]
		params[:lang] = params[:language]
		get_language
	end

       if RAILS_ENV == 'development'
      		@paypal_url = "http://www.sandbox.paypal.com/cgi-bin/webscr"
		@paypal_user = "seller_1185156568_biz@yahoo.com"
  	else
    		@paypal_url = "https://www.paypal.com/cgi-bin/webscr"
		@paypal_user = "finance@kabbalah.info"
  	end

	@xxxFirstName = params[:xxxFirstName] || ""
	@xxxFirstName = CGI::unescape(@xxxFirstName)
	@xxxLastName = params[:xxxLastName] || ""
	@xxxLastName = CGI::unescape(@xxxLastName)
	@xxxCountry = params[:xxxCountry] || "Unknown"
	@xxxEmail = params[:xxxEmail] || ""
	@xxxEmail = CGI::unescape(@xxxEmail)
	@message = params[:message] || ""
	@message = CGI::unescape(@message)	
	@xxxProject = params[:xxxProject] || "0"
	@sum = params[:sum] || ""
	@anon = params[:anon] || "0"
	@timestamp = params[:timestamp]

     if (params[:sum])

     	@donor = Donor.new(:name => @xxxFirstName + " " + @xxxLastName,  
	   	  	     :country => @xxxCountry, 
			     #:city => "", 
			     #:region => "", 
			     :email => @xxxEmail,
			     :message => @message,
			     :sum_dollars => @sum,
			     :is_anonymous => @anon,  
			     :payment_id => Payment.get_payment_id_by_code("electronic"), 
			     :project_id => @xxxProject.to_i, 
			     :approved => false, 
			     :is_new => true,
			     :eptype => "PayPal",
			     :created_at => @timestamp,
			     :currency_id => Currency.find_currencies_id_by_name("$"))					  		     
	 @donor.save

	else

	 render :layout => "paypal"

	end
  end


  def tranzilla
    set_params false
	if params[:language] && @lang != params[:language]
		params[:lang] = params[:language]
		get_language
	end
			
	@user = Common.get_user_by_lang(@lang)
	@first_pay = params[:fpay] || ""
	@second_pay = params[:spay] || ""

	if (@lang == "Hebrew")
		@currency = params[:currency] || "1"
	else
		@currency = params[:currency] || "2"
	end

	@sum = params[:sum] || ""
	@cred_type = params[:cred_type] || "1"
	@npay = params[:npay] || "1"
	@xxxFirstName = params[:xxxFirstName] || ""
	@xxxFirstName = CGI::unescape(@xxxFirstName)
	@xxxLastName = params[:xxxLastName] || ""
	@xxxLastName = CGI::unescape(@xxxLastName)
	@ccno = params[:ccno] || ""
	@expmonth = params[:expmonth] || "1"
	@expyear = params[:expyear] || "7"
	@mycvv = params[:mycvv] || ""
	@myid = params[:myid] || ""
	@anon = params[:anon] || "0"
	@xxxEmail = params[:xxxEmail] || ""
	@xxxEmail = CGI::unescape(@xxxEmail)
	@message = params[:message] || ""
	@message = CGI::unescape(@message)	
	@xxxCountry = params[:xxxCountry] || "Unknown"
  @xxxCCType = params[:xxxCCType] || "Visa"
	@xxxProject = params[:xxxProject] || "0"

  flash[:notice] = ""
	@response = 1
	
	if (params[:sum])

    myrequest = "supplier=#{@user}&sum=#{@sum}&xxxProject=#{@xxxProject}&xxxCountry=#{@xxxCountry}&xxxEmail=#{@xxxEmail}&message=#{@message}&anon=#{@anon}&mycvv=#{@mycvv}&myid=#{@myid}&cred_type=#{@cred_type}&npay=#{@npay}&currency=#{@currency}&fpay=#{@first_pay}&spay=#{@second_pay}&xxxFirstName=#{@xxxFirstName}&xxxLastName=#{@xxxLastName}&ccno=#{@ccno}&expmonth=#{@expmonth}&expyear=#{@expyear}&myid=#{@myid}\r\n"
    ctx = OpenSSL::SSL::SSLContext.new
    t = TCPSocket.new('secure.tranzila.com','https')
    ssl = OpenSSL::SSL::SSLSocket.new(t, ctx)
    ssl.sync_close = true
    ssl.connect

    ssl.puts("POST /cgi-bin/tranzila31.cgi HTTPs/1.1\r\n")
    ssl.puts("Host: secure.tranzila.com\r\n")
    ssl.puts("User-Agent: Bnei Baruch\r\n")
    ssl.puts("Content-Type: application/x-www-form-urlencoded\r\n")
    ssl.puts("Content-Length: #{myrequest.length}\r\n")
    ssl.puts("\r\n")
    ssl.puts(myrequest)

		while res = ssl.gets
			@ret_params = CGI::parse(res)
			if (@ret_params["Response"][0])	
				@response = @ret_params["Response"][0].to_i
				flash[:notice] = case @response
					when 0   : ""
					when 1   : '_' + @response.to_s
					when 3   : '_' + @response.to_s
					when 4   : '_' + @response.to_s
					when 6   : '_' + @response.to_s
					when 33  : '_' + @response.to_s
					when 35  : '_' + @response.to_s
					when 36  : '_' + @response.to_s
					when 37  : '_' + @response.to_s
					when 39  : '_' + @response.to_s
					when 57  : '_' + @response.to_s
					when 61  : '_' + @response.to_s
					when 107 : '_' + @response.to_s
					when 111 : '_' + @response.to_s
					when 138 : '_' + @response.to_s
					when 139 : '_' + @response.to_s
					else "Error"
				end
				
				if (@response == 0)
				 	if (@currency == "1")
						@currency_id = Currency.find_currencies_id_by_name("NIS")
					else
						@currency_id = Currency.find_currencies_id_by_name("$")
					end

					@donor = Donor.new(:name => @xxxFirstName + " " + @xxxLastName, 
                            :country => @xxxCountry,
                            #:city => "",
                            #:region => "",
                            :email => @xxxEmail,
                            :message => @message,
                            :sum_dollars => @sum,
                            :is_anonymous => @anon,
                            :payment_id => Payment.get_payment_id_by_code("electronic"),
                            :project_id => @xxxProject.to_i,
                            :approved => false,
                            :acked => true,
                            :eptype => "Tranzila",
                            :currency_id => @currency_id)
					@err = @donor.save

          #send to iCount instead of email
          #send_ack_email(@xxxEmail, @xxxFirstName + " " + @xxxLastName, @sum.to_s, @donor.currency.name)
          send_to_icount(@donor.name, @donor.country, @donor.email, @donor.sum_dollars,
                         @donor.currency_id, @xxxCCType, @npay.to_i, @first_pay.to_i)
				end
				# Break if @ret_params["Response"][0]
				break
			end
		end
	    ssl.close
	end 
	
	  if (@response != 0)
		  render :layout => "tranzilla"
	  else
		  render :partial => "thank_you", :layout => false
	  end	
  end

  def sochi
    set_params false
	
	if params[:language] && @lang != params[:language]
		params[:lang] = params[:language]
		get_language
	end
			
	@user = Common.get_user_by_lang(@lang)
	@first_pay = params[:fpay] || ""
	@second_pay = params[:spay] || ""

	if (@lang == "Hebrew")
		@currency = params[:currency] || "1"
	else
		@currency = params[:currency] || "2"
	end

	@sum = params[:sum] || ""
	@cred_type = params[:cred_type] || "1"
	@npay = params[:npay] || "1"
	@xxxFirstName = params[:xxxFirstName] || ""
	@xxxFirstName = CGI::unescape(@xxxFirstName)
	@xxxLastName = params[:xxxLastName] || ""
	@xxxLastName = CGI::unescape(@xxxLastName)
	@ccno = params[:ccno] || ""
	@expmonth = params[:expmonth] || "1"
	@expyear = params[:expyear] || "7"
	@mycvv = params[:mycvv] || ""
	@myid = params[:myid] || ""
	@anon = params[:anon] || "0"
	@xxxEmail = params[:xxxEmail] || ""
	@xxxEmail = CGI::unescape(@xxxEmail)
	@message = params[:message] || ""
	@message = CGI::unescape(@message)	
	@xxxCountry = params[:xxxCountry] || "Unknown"
	@xxxProject = "Sochi"

    flash[:notice] = ""
	@response = 1
	
	if (params[:sum])
	       myrequest = "supplier=#{@user}&sum=#{@sum}&xxxProject=#{@xxxProject}&xxxCountry=#{@xxxCountry}&xxxEmail=#{@xxxEmail}&message=#{@message}&anon=#{@anon}&mycvv=#{@mycvv}&myid=#{@myid}&cred_type=#{@cred_type}&npay=#{@npay}&currency=#{@currency}&fpay=#{@first_pay}&spay=#{@second_pay}&xxxFirstName=#{@xxxFirstName}&xxxLastName=#{@xxxLastName}&ccno=#{@ccno}&expmonth=#{@expmonth}&expyear=#{@expyear}&myid=#{@myid}\r\n"
    		ctx = OpenSSL::SSL::SSLContext.new
   		t = TCPSocket.new('secure.tranzila.com','https')
     		ssl = OpenSSL::SSL::SSLSocket.new(t, ctx)
	       ssl.sync_close = true
 	       ssl.connect

	       ssl.puts("POST /cgi-bin/tranzila31.cgi HTTPs/1.1\r\n")
		ssl.puts("Host: secure.tranzila.com\r\n")
    		ssl.puts("User-Agent: Bnei Baruch\r\n")
		ssl.puts("Content-Type: application/x-www-form-urlencoded\r\n")
   	 	ssl.puts("Content-Length: #{myrequest.length}\r\n")
     		ssl.puts("\r\n")
    		ssl.puts(myrequest)
		while res = ssl.gets
			@ret_params = CGI::parse(res)
			if (@ret_params["Response"][0])	
				@response = @ret_params["Response"][0].to_i
				flash[:notice] = case @response
					when 0   : ""
					when 1   : '_' + @response.to_s
					when 3   : '_' + @response.to_s
					when 4   : '_' + @response.to_s
					when 6   : '_' + @response.to_s
					when 33  : '_' + @response.to_s
					when 35  : '_' + @response.to_s
					when 36  : '_' + @response.to_s
					when 37  : '_' + @response.to_s
					when 39  : '_' + @response.to_s
					when 57  : '_' + @response.to_s
					when 61  : '_' + @response.to_s
					when 107 : '_' + @response.to_s
					when 111 : '_' + @response.to_s
					when 138 : '_' + @response.to_s
					when 139 : '_' + @response.to_s
					else "Error"
				end
				
				if (@response == 0)
				 	if (@currency == "1")
						@currency_id = Currency.find_currencies_id_by_name("NIS")
					else
						@currency_id = Currency.find_currencies_id_by_name("$")
					end

					@donor = Donor.new(:name => @xxxFirstName + " " + @xxxLastName, 
		       			    	     :country => @xxxCountry, 
			     				     #:city => "", 
							     #:region => "", 
							     :email => @xxxEmail,
				  			     :message => @message, 
							     :sum_dollars => @sum, 
							     :is_anonymous => @anon, 
							     :payment_id => Payment.get_payment_id_by_code("electronic"), 
					  		     #:project_id => @xxxProject.to_i, 
						  	     :approved => false,
							     :acked => true, 
							     :eptype => "Tranzila",
							     :currency_id => @currency_id)
					@err= @donor.save
					send_ack_email(@xxxEmail, @xxxFirstName + " " + @xxxLastName, @sum.to_s, @donor.currency.name)
				end
				# Break if @ret_params["Response"][0]
				break
			end
		end
	    ssl.close
	end 
	
	  if (@response != 0)
		  render :layout => "sochi"
	  else
		  render :partial => "thank_you", :layout => false
	  end	
  end

  def yandex
	set_params false
	render :layout => "yandex"
  end	

  def thank_you # return from tranzilla after payment was made
       set_params false
	render :layout => "tranzilla"
  end

  def thank_you_paypal # return from PayPal after payment was made
       set_params false
	render :layout => false
  end

  def cancel_paypal # return from PayPal after payment was canceled
       set_params false
	render :layout => false
  end

  def paypal_ipn
       set_params false

  	@notify = Paypal::Notification.new(request.raw_post)
       if true #@notify.acknowledge
		@donor = Donor.find_by_acked_and_is_new_and_created_at(false, true, @notify.item_id)	

		if (@donor)
			if (@notify.complete?)
				@donor.acked = true	
				@donor.save
        send_ack_email(@donor.email, @donor.name, @donor.sum_dollars.to_s, @donor.currency.name)
			else
				@donor.destroy
			end
		end
	end

	render :layout => false
  end

  #################### WebMoney Functions ##########################	

  def webmoney
	set_params false
	
	if params[:language] && @lang != params[:language]
		params[:lang] = params[:language]
		get_language
	end
			
	#@webmoney_rub_purse = Common.get_webmoney_rub_purse_by_lang(@lang)
	#@webmoney_dol_purse = Common.get_webmoney_dol_purse_by_lang(@lang)
	#@webmoney_eur_purse = Common.get_webmoney_eur_purse_by_lang(@lang)

	@webmoney_rub_purse = "R325349133575"
	@webmoney_dol_purse = "Z301940718631"
	@webmoney_eur_purse = "E335388151063"

	@currency = params[:currency] || @webmoney_rub_purse
	@xxxFirstName = params[:xxxFirstName] || ""
	@xxxFirstName = CGI::unescape(@xxxFirstName)
	@xxxLastName = params[:xxxLastName] || ""
	@xxxLastName = CGI::unescape(@xxxLastName)
	@xxxCountry = params[:xxxCountry] || "Unknown"
	@xxxEmail = params[:xxxEmail] || ""
	@xxxEmail = CGI::unescape(@xxxEmail)
	@message = params[:message] || ""
	@message = CGI::unescape(@message)	
	@xxxProject = params[:xxxProject] || "0"
	@sum = params[:sum] || ""
	@anon = params[:anon] || "0"
	@timestamp = params[:timestamp] || "0"

    if (params[:sum])
		case @currency
			when @webmoney_rub_purse: currency_id = Currency.find_currencies_id_by_name("RUB")
			when @webmoney_dol_purse: currency_id = Currency.find_currencies_id_by_name("$")
			when @webmoney_eur_purse: currency_id = Currency.find_currencies_id_by_name("EUR")
		end

     	@donor = Donor.new(:name => @xxxFirstName + " " + @xxxLastName,  
	   	  				 :country => @xxxCountry, 
						 :email => @xxxEmail,
						 :message => @message,
						 :sum_dollars => @sum,
						 :is_anonymous => @anon,  
						 :payment_id => Payment.get_payment_id_by_code("electronic"), 
						 :project_id => @xxxProject.to_i, 
						 :approved => false, 
						 :is_new => true,
						 :eptype => "WebMoney",
						 :created_at => Time.at(@timestamp.to_i).to_s,
						 :currency_id => currency_id)					  		     
		@donor.save
	else
		render :layout => "webmoney"
	end
  end	

  def webmoney_success # return from Webmoney after successful payment
    set_params false
	
	id = params[:LMI_PAYMENT_NO]
	donor = Donor.find_by_acked_and_is_new_and_created_at(false, true, Time.at(id.to_i))	

	if (donor)
		donor.acked = true	
		donor.save
    send_ack_email(donor.email, donor.name, donor.sum_dollars.to_s, donor.currency.name)
	end

	render :layout => false
  end

  def webmoney_fail # return from Webmoney after failed payment
	set_params false
	
	id = params[:LMI_PAYMENT_NO]
	donor = Donor.find_by_acked_and_is_new_and_created_at(false, true, Time.at(id.to_i))	

	if (donor)
		donor.destroy
	end

	render :layout => false
  end


  #################### CONGRESS DONATION ##########################

  def congress_don
    
	set_params false
	
	if params[:language] && @lang != params[:language]
		params[:lang] = params[:language]
		get_language
	end
			
	@user = Common.get_user_by_lang(@lang)
	@first_pay = params[:fpay] || ""
	@second_pay = params[:spay] || ""

	if (@lang == "Hebrew")
		@currency = params[:currency] || "1"
	else
		@currency = params[:currency] || "2"
	end

	@sum = params[:sum] || ""
	@cred_type = params[:cred_type] || "1"
	@npay = params[:npay] || "1"
	@xxxFirstName = params[:xxxFirstName] || ""
	@xxxFirstName = CGI::unescape(@xxxFirstName)
	@xxxLastName = params[:xxxLastName] || ""
	@xxxLastName = CGI::unescape(@xxxLastName)
	@ccno = params[:ccno] || ""
	@expmonth = params[:expmonth] || "1"
	@expyear = params[:expyear] || "7"
	@mycvv = params[:mycvv] || ""
	@myid = params[:myid] || ""
	@anon = params[:anon] || "0"
	@xxxEmail = params[:xxxEmail] || ""
	@xxxEmail = CGI::unescape(@xxxEmail)
	@message = params[:message] || ""
	@message = CGI::unescape(@message)	
	@xxxCountry = params[:xxxCountry] || "Unknown"
	@xxxProject = "Congress 2009"

    flash[:notice] = ""
	@response = 1
	
	if (params[:sum])
	    myrequest = "supplier=#{@user}&sum=#{@sum}&xxxProject=#{@xxxProject}&xxxCountry=#{@xxxCountry}&xxxEmail=#{@xxxEmail}&message=#{@message}&anon=#{@anon}&mycvv=#{@mycvv}&myid=#{@myid}&cred_type=#{@cred_type}&npay=#{@npay}&currency=#{@currency}&fpay=#{@first_pay}&spay=#{@second_pay}&xxxFirstName=#{@xxxFirstName}&xxxLastName=#{@xxxLastName}&ccno=#{@ccno}&expmonth=#{@expmonth}&expyear=#{@expyear}&myid=#{@myid}\r\n"
    	ctx = OpenSSL::SSL::SSLContext.new
   		t = TCPSocket.new('secure.tranzila.com','https')
		ssl = OpenSSL::SSL::SSLSocket.new(t, ctx)
	    ssl.sync_close = true
 	    ssl.connect

	    ssl.puts("POST /cgi-bin/tranzila31.cgi HTTPs/1.1\r\n")
		ssl.puts("Host: secure.tranzila.com\r\n")
    	ssl.puts("User-Agent: Bnei Baruch\r\n")
		ssl.puts("Content-Type: application/x-www-form-urlencoded\r\n")
   	 	ssl.puts("Content-Length: #{myrequest.length}\r\n")
     	ssl.puts("\r\n")
    	ssl.puts(myrequest)
		while res = ssl.gets
			@ret_params = CGI::parse(res)
			if (@ret_params["Response"][0])	
				@response = @ret_params["Response"][0].to_i
				flash[:notice] = case @response
					when 0   : ""
					when 1   : '_' + @response.to_s
					when 3   : '_' + @response.to_s
					when 4   : '_' + @response.to_s
					when 6   : '_' + @response.to_s
					when 33  : '_' + @response.to_s
					when 35  : '_' + @response.to_s
					when 36  : '_' + @response.to_s
					when 37  : '_' + @response.to_s
					when 39  : '_' + @response.to_s
					when 57  : '_' + @response.to_s
					when 61  : '_' + @response.to_s
					when 107 : '_' + @response.to_s
					when 111 : '_' + @response.to_s
					when 138 : '_' + @response.to_s
					when 139 : '_' + @response.to_s
					else "Error"
				end
				
				if (@response == 0)
				 	if (@currency == "1")
						@currency_id = Currency.find_currencies_id_by_name("NIS")
					else
						@currency_id = Currency.find_currencies_id_by_name("$")
					end

					@donor = Donor.new(:name => @xxxFirstName + " " + @xxxLastName, 
		       			    	       :country => @xxxCountry, 
			     						#:city => "", 
										#:region => "", 
										:email => @xxxEmail,
				  						:message => @message, 
										:sum_dollars => @sum, 
										:is_anonymous => @anon, 
										:payment_id => Payment.get_payment_id_by_code("electronic"), 
					  					:project_id => 29, 
						  				:approved => false,
										:acked => true, 
										:eptype => "Tranzila",
										:currency_id => @currency_id)
					@err= @donor.save
					send_ack_email(@xxxEmail, @xxxFirstName + " " + @xxxLastName, @sum.to_s, @donor.currency.name)
				end
				# Break if @ret_params["Response"][0]
				break
			end
		end
	    ssl.close
	end 
	
	  if (@response != 0)
		  render :layout => "congress_don"
	  else
		  render :partial => "thank_you", :layout => false
	  end	
  end


#################### KABBALAH STATE DONATION ##########################

  def kab_state
    
	set_params false
	
	if params[:language] && @lang != params[:language]
		params[:lang] = params[:language]
		get_language
	end
			
	@user = Common.get_user_by_lang(@lang)
	@first_pay = params[:fpay] || ""
	@second_pay = params[:spay] || ""

	if (@lang == "Hebrew")
		@currency = params[:currency] || "1"
	else
		@currency = params[:currency] || "2"
	end

	@sum = params[:sum] || ""
	@cred_type = params[:cred_type] || "1"
	@npay = params[:npay] || "1"
	@xxxFirstName = params[:xxxFirstName] || ""
	@xxxFirstName = CGI::unescape(@xxxFirstName)
	@xxxLastName = params[:xxxLastName] || ""
	@xxxLastName = CGI::unescape(@xxxLastName)
	@ccno = params[:ccno] || ""
	@expmonth = params[:expmonth] || "1"
	@expyear = params[:expyear] || "7"
	@mycvv = params[:mycvv] || ""
	@myid = params[:myid] || ""
	@anon = params[:anon] || "0"
	@xxxEmail = params[:xxxEmail] || ""
	@xxxEmail = CGI::unescape(@xxxEmail)
	@message = params[:message] || ""
	@message = CGI::unescape(@message)	
	@xxxCountry = params[:xxxCountry] || "Unknown"
	@xxxProject = "Kabbalah State"

    flash[:notice] = ""
	@response = 1
	
	if (params[:sum])
	    myrequest = "supplier=#{@user}&sum=#{@sum}&xxxProject=#{@xxxProject}&xxxCountry=#{@xxxCountry}&xxxEmail=#{@xxxEmail}&message=#{@message}&anon=#{@anon}&mycvv=#{@mycvv}&myid=#{@myid}&cred_type=#{@cred_type}&npay=#{@npay}&currency=#{@currency}&fpay=#{@first_pay}&spay=#{@second_pay}&xxxFirstName=#{@xxxFirstName}&xxxLastName=#{@xxxLastName}&ccno=#{@ccno}&expmonth=#{@expmonth}&expyear=#{@expyear}&myid=#{@myid}\r\n"
    	ctx = OpenSSL::SSL::SSLContext.new
   		t = TCPSocket.new('secure.tranzila.com','https')
		ssl = OpenSSL::SSL::SSLSocket.new(t, ctx)
	    ssl.sync_close = true
 	    ssl.connect

	    ssl.puts("POST /cgi-bin/tranzila31.cgi HTTPs/1.1\r\n")
		ssl.puts("Host: secure.tranzila.com\r\n")
    	ssl.puts("User-Agent: Bnei Baruch\r\n")
		ssl.puts("Content-Type: application/x-www-form-urlencoded\r\n")
   	 	ssl.puts("Content-Length: #{myrequest.length}\r\n")
     	ssl.puts("\r\n")
    	ssl.puts(myrequest)
		while res = ssl.gets
			@ret_params = CGI::parse(res)
			if (@ret_params["Response"][0])	
				@response = @ret_params["Response"][0].to_i
				flash[:notice] = case @response
					when 0   : ""
					when 1   : '_' + @response.to_s
					when 3   : '_' + @response.to_s
					when 4   : '_' + @response.to_s
					when 6   : '_' + @response.to_s
					when 33  : '_' + @response.to_s
					when 35  : '_' + @response.to_s
					when 36  : '_' + @response.to_s
					when 37  : '_' + @response.to_s
					when 39  : '_' + @response.to_s
					when 57  : '_' + @response.to_s
					when 61  : '_' + @response.to_s
					when 107 : '_' + @response.to_s
					when 111 : '_' + @response.to_s
					when 138 : '_' + @response.to_s
					when 139 : '_' + @response.to_s
					else "Error"
				end
				
				if (@response == 0)
				 	if (@currency == "1")
						@currency_id = Currency.find_currencies_id_by_name("NIS")
					else
						@currency_id = Currency.find_currencies_id_by_name("$")
					end

					@donor = Donor.new(:name => @xxxFirstName + " " + @xxxLastName, 
		       			    	       :country => @xxxCountry, 
			     						#:city => "", 
										#:region => "", 
										:email => @xxxEmail,
				  						:message => @message, 
										:sum_dollars => @sum, 
										:is_anonymous => @anon, 
										:payment_id => Payment.get_payment_id_by_code("electronic"), 
					  					:project_id => 30, 
						  				:approved => false,
										:acked => true, 
										:eptype => "Tranzila",
										:currency_id => @currency_id)
					@err= @donor.save
					send_ack_email(@xxxEmail, @xxxFirstName + " " + @xxxLastName, @sum.to_s, @donor.currency.name)
				end
				# Break if @ret_params["Response"][0]
				break
			end
		end
	    ssl.close
	end 
	
	  if (@response != 0)
		  render :layout => "kab_state"
	  else
		  render :partial => "thank_you", :layout => false
	  end	
  end

   #################### PER PROJECT DONORS LIST ##########################
   def project_donors_list
	 set_params false

	 donors_per_page = 0
	 if params.has_key?(:project_id)
		@donors = Donor.get_donors_per_project(true, true, params[:project_id], params[:sidx], params[:sord])
		@donors.each do |d|
			 d.name = _('Anonymous') if d.is_anonymous
			 d.country = "&nbsp;" if d.country == "Unknown" || d.country == "."
			 d.message = "&nbsp;" if d.message.empty?
		end

		donors_per_page = params.has_key?(:rows) ? params[:rows].to_i : 10
		if params.has_key?(:page)
			page_num = params[:page].to_i - 1
		else
			page_num = 0
			donors_per_page = @donors.size
		end
		offset = donors_per_page * page_num

		if offset >= @donors.size
			donors_per_page = 0 
		elsif @donors.size - offset < donors_per_page
			donors_per_page = @donors.size - offset 
		end
	 else
		 @donors = []
	 end

	 if (params[:mode] == 'xml')
		doc = REXML::Document.new(donors_per_page > 0 ? (@donors[offset, donors_per_page]).to_xml : '<donors></donors>')
		doc.root.add_attributes({"grandtotal", @donors ? @donors.size.to_s : '0'})
		doc.root.add_attributes({"total", donors_per_page.to_s})
		render :xml => doc.to_s
	 else
		total = @donors.size.to_f / donors_per_page
		page = page_num + 1
		records = @donors.size
		res = {:total => total.ceil.to_s,
			:page => page.to_s,
			:records => records.to_s,
			:rows => @donors[offset, donors_per_page.to_i].map{|d|
				{:id => d.id.to_s,
				 :cell => [d.name, d.sum_dollars.to_s, d.country, d.created_at.strftime('%Y-%m-%d'), d.message]
				}
			}
		}.to_json
		if params[:callback]
			res = "#{params[:callback]}(#{res});"
		end

		render :json => res
	 end
  end

  private ######### PRIVATE FUNCTIONS #########################

  def send_ack_email(email, name, sum, currency)
	if (!email.nil? && !email.empty?)
		acknowledge = ContactUsMailer.create_acknowledge(@lang, email, name, sum, currency)
		ContactUsMailer.deliver(acknowledge)
	end
  end
  
  def set_params(to_render = true)
	 get_language
	 @action = action_name
	 if (@action == "window_privacy_and_security")
		 @action = "privacy_and_security"
	 elsif (@action == "index")
		 @action = "main"
	 elsif (@action == "thank_you_paypal")
		 @action = "thank_you"
    end

  	 @page_title = get_page_component(@lang, @action, "_page_title")
	 @page_content_short = get_page_component(@lang, @action, "_page_short")
	 @page_content = get_page_component(@lang, @action, "_page")

	 @payments = get_payments(@lang)
	 @host = request.env["HTTP_HOST"]
    render :action => "main" if to_render
  end

  def get_language
	lang_name = "English"
	@rtl = false
	if params[:lang]
		lang = params[:lang].downcase
		l_obj = Language.find(:first, :conditions => ["short_name = ?", lang])
		if !l_obj.nil?
			lang_name = l_obj.name
			@rtl = (l_obj.direction || "ltr") == "rtl"
		else
			l_obj = Language.find(:first, :conditions => ["name = ?", lang.capitalize])
			if !l_obj.nil?
				lang_name = l_obj.name
				@rtl = (l_obj.direction || "ltr") == "rtl"
			end
		end
	end
	Localization.lang = lang_name
	@privacy_and_security = url_for(:controller => "user", :action => "window_privacy_and_security")
	@tranzilla = url_for(:protocol => (RAILS_ENV == "production" ? "https://" : "http://"), :controller => "user", :action => "tranzilla")
	@paypal = url_for(:protocol => (RAILS_ENV == "production" ? "https://" : "http://"), :controller => "user", :action => "paypal")
	@bank_details = url_for(:controller => "user", :action => "bank_details")
	@webmoney = url_for(:protocol => (RAILS_ENV == "production" ? "https://" : "http://"), :controller => "user", :action => "webmoney")
	@yandex = url_for(:controller => "user", :action => "yandex")		
	@lang = lang_name

	if RAILS_ENV == 'development'
		@path_don = 'don'
	else
		@path_don = 'donations'
	end
  end

  def get_page_component(lang, action, suffix)
    page_contents = PageContent.get_page_content_by_lang(lang)
    if page_contents.nil?
      ""
    else
      page_contents[action + suffix]
    end
  end

  def get_payments(lang)
	  Payment.all_payments_by_lang(lang)
  end

  def paypal_save
	set_params false

	@donor = Donor.new(:name => "DIMA", 
		    	     :country => "Israel", 
			     #:city => "", 
			     #:region => "", 
			     :email => "dpol_bb@yahoo.com",
			     :message => "HI", 
			     :sum_dollars => 0, 
			     :is_anonymous => "0", 
			     :payment_id => Payment.get_payment_id_by_code("electronic"), 
			     :project_id => 0, 
		 	     :approved => false, 
			     :currency_id => 0)
	@donor.save

	render :layout => "user"
  end

  def get_credit_card_type(card_num)
     card_regexes = Hash[
        /^4\d{12}(\d\d\d){0,1}$/ => "Visa",
        /^5[12345]\d{14}$/       => "MasterCard",
        /^3[47]\d{13}$/          => "Amex",
        /^6011\d{12}$/           => "Discover",
        /^30[012345]\d{11}$/     => "Diners",
        /^3[68]\d{12}$/          => "Diners",
        /^\d{7}$/                => "Isracard",
        /^\d{8}$/                => "Isracard",
        /^\d{9}$/                => "Isracard"]

    card_type = "Unknown"
    card_regexes.each {|regex, type|
      if (regex.match(card_num))
           card_type = type
           break;
       end
    }
    return card_type
  end

  def send_to_icount(name, country, email, sum, currency_id, cc_type, npay = 1, fpay = 0)

    #send to iCount
    comp_id  = "bneibaruch"
    user     = "bb"
    pass     = "an1711"

    doc_type = "receipt"
    income_type_name = "Donations"
    es = _('Bnei Baruch - Payment confirmation')

    case currency_id
			when Currency.find_currencies_id_by_name("RUB"): 
          currency_icount = "7"
          currency_name   = "RUB"
			when Currency.find_currencies_id_by_name("$"):
          currency_icount = "2"
          currency_name   = "$"
			when Currency.find_currencies_id_by_name("EUR"):
          currency_icount = "1"
          currency_name   = "EUR"
      else
          currency_icount = "5" #NIS
          currency_name   = "NIS"
		end

#    hwc = _('This is to confirm that your donation of') + " #{currency_name}#{sum} "  +
#          _('to Bnei Baruch has been received, and will go toward helping share the wisdom of Kabbalah.') + ' ' +
#          _('Thank you for your support!')

    hwc = _('Donations')

    email_lang  = (@lang == "Hebrew") ? "he" : "en"

    icount_fields = "compID=#{comp_id}&user=#{user}&pass=#{pass}&docType=#{doc_type}&hwc=#{hwc}&income_type_name=#{income_type_name}&es=#{es}&"
    if (email_lang == "he")
      icount_fields = icount_fields + "eft=קבלה על תשלום תרומתך תוכל לקבל בלינק המצורף: &"
    end
    icount_fields = icount_fields + "clientname=#{name}&"
    icount_fields = icount_fields + "client_country=#{country}&"
    icount_fields = icount_fields + "credit=1&cc_cardtype[0]=#{cc_type}&cctotal[0]=#{sum}&"
    if npay > 1
      npay = (sum.to_i / fpay.to_f).round()
      icount_fields = icount_fields + "&cc_numofpayments[]=#{npay}&ccfirstpayment[]=#{fpay}&"
    end
    icount_fields = icount_fields + "currency=#{currency_icount}&"
    icount_fields = icount_fields + "lang=#{email_lang}&sendOrig=#{email}&" + "\r\n"
    Curl::Easy.http_post("https://www.icount.co.il/api/create_doc_auto.php", icount_fields)

    #flash[:notice] = c.body_str
  end
end
