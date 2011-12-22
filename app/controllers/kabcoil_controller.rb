require 'cgi'

require 'socket'
require 'openssl'
require 'net/http'
require 'uri'
require 'rest_client'

class KabcoilController < ApplicationController

  layout 'kabcoil'

  def index
    set_params
    @external = true

    @items_per_page = 10
    if params['page'] == "-1"
      @items_per_page = 10000000
    end
    sort = case params['sort']
             when "date" :
               "created_at"
             when "name" :
               "name"
             when "country" :
               "country"
             when "sum" :
               "sum_dollars"
             when "date_reverse" :
               "created_at DESC"
             when "name_reverse" :
               "name DESC"
             when "country_reverse" :
               "country DESC"
             when "sum_reverse" :
               "sum_dollars DESC"

             else
               "created_at DESC"
           end

    @donors_pages, @donors = paginate :donors,
                                      :conditions => ["approved = ? OR acked = ?", true, true],
                                      :per_page => @items_per_page,
                                      :order => sort
    @donors.each do |d|
      d.name = _('Anonymous') if d.is_anonymous
      d.country = "" if d.country == "Unknown" || d.country == "."
      d.message = " " if d.message.empty?
    end

    if request.xhr?
      render :partial => "donors_list", :layout => false
      return
    end

  end

  def tranzilla
    set_params
    @external = false
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
    @xxxCountry = params[:xxxCountry] || '- ' + _('Country') + ' -'
    @xxxCCType = params[:xxxCCType] || "Visa"
    @xxxProject = params[:xxxProject] || "0"

    flash[:notice] = ""
    @response = 1

    if (params[:sum])

      myrequest = "supplier=#{@user}&sum=#{@sum}&xxxProject=#{@xxxProject}&xxxCountry=#{@xxxCountry}&xxxEmail=#{@xxxEmail}&message=#{@message}&anon=#{@anon}&mycvv=#{@mycvv}&myid=#{@myid}&cred_type=#{@cred_type}&npay=#{@npay}&currency=#{@currency}&fpay=#{@first_pay}&spay=#{@second_pay}&xxxFirstName=#{@xxxFirstName}&xxxLastName=#{@xxxLastName}&ccno=#{@ccno}&expmonth=#{@expmonth}&expyear=#{@expyear}&myid=#{@myid}"
      ctx = OpenSSL::SSL::SSLContext.new
      t = TCPSocket.new('secure.tranzila.com', 'https')
      ssl = OpenSSL::SSL::SSLSocket.new(t, ctx)
      ssl.sync_close = true
      ssl.connect

      if  @currency == "978"
        ssl.puts("POST /cgi-bin/tranzila36a.cgi HTTPs/1.1\r\n")
      else
        ssl.puts("POST /cgi-bin/tranzila31.cgi HTTPs/1.1\r\n")
      end
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
                             when 0 :
                               ""
                             when 1 :
                               '_' + @response.to_s
                             when 3 :
                               '_' + @response.to_s
                             when 4 :
                               '_' + @response.to_s
                             when 6 :
                               '_' + @response.to_s
                             when 33 :
                               '_' + @response.to_s
                             when 35 :
                               '_' + @response.to_s
                             when 36 :
                               '_' + @response.to_s
                             when 37 :
                               '_' + @response.to_s
                             when 39 :
                               '_' + @response.to_s
                             when 57 :
                               '_' + @response.to_s
                             when 61 :
                               '_' + @response.to_s
                             when 107 :
                               '_' + @response.to_s
                             when 111 :
                               '_' + @response.to_s
                             when 138 :
                               '_' + @response.to_s
                             when 139 :
                               '_' + @response.to_s
                             else
                               "Error"
                           end

          if (@response == 0)
            @currency_id = case @currency
                             when "1" :
                               Currency.find_currencies_id_by_name("NIS")
                             when "2" :
                               Currency.find_currencies_id_by_name("$")
                             when "978" :
                               Currency.find_currencies_id_by_name("EUR")
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
      render :layout => "kabcoil"
    else
      render :partial => "thank_you1", :layout => false
    end
  end

  private
  def set_params
    get_language
    @action = action_name

    @page_title = get_page_component(@lang, @action, "_page_title")
    @page_content_short = get_page_component(@lang, @action, "_page_short")
    @page_content = get_page_component(@lang, @action, "_page")

    @payments = get_payments(@lang)
    @host = request.env["HTTP_HOST"]
  end

  def get_language
    lang_name = "English"
    @rtl = false
    if params[:lang]
      langa = params[:lang]
      langd = params[:lang].downcase
      l_obj = Language.find(:first, :conditions => ["short_name = ? OR short_name = ?", langa, langd])
      if !l_obj.nil?
        lang_name = l_obj.name
        @rtl = (l_obj.direction || "ltr") == "rtl"
      else
        l_obj = Language.find(:first, :conditions => ["name = ?", langd.capitalize])
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

end
