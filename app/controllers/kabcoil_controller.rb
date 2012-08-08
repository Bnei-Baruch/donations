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
    @agree_to_receive_emails = params[:agree_to_receive_emails] == '1' || false

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
      #ZZZ ctx = OpenSSL::SSL::SSLContext.new
      #ZZZ t = TCPSocket.new('secure.tranzila.com', 'https')
      #ZZZ ssl = OpenSSL::SSL::SSLSocket.new(t, ctx)
      #ZZZ ssl.sync_close = true
      #ZZZ ssl.connect

      #ZZZ if  @currency == "978"
        #ZZZ ssl.puts("POST /cgi-bin/tranzila36a.cgi HTTPs/1.1\r\n")
      #ZZZ else
        #ZZZ ssl.puts("POST /cgi-bin/tranzila31.cgi HTTPs/1.1\r\n")
      #ZZZ end
      #ZZZ ssl.puts("Host: secure.tranzila.com\r\n")
      #ZZZ ssl.puts("User-Agent: Bnei Baruch\r\n")
      #ZZZ ssl.puts("Content-Type: application/x-www-form-urlencoded\r\n")
      #ZZZ ssl.puts("Content-Length: #{myrequest.length}\r\n")
      #ZZZ ssl.puts("\r\n")
      #ZZZ ssl.puts(myrequest)

      while res = 1 #ZZZssl.gets
        @ret_params = 1 #ZZZ CGI::parse(res)
        #ZZZif (@ret_params["Response"][0])
        if true
          #ZZZ @response = @ret_params["Response"][0].to_i
          @response = 0#ZZZ@ret_params["Response"][0].to_i
          #ZZZ flash[:notice] = case @response
                             #ZZZ when 0 :
                               #ZZZ ""
                             #ZZZ when 1 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 3 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 4 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 6 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 33 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 35 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 36 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 37 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 39 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 57 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 61 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 107 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 111 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 138 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ when 139 :
                               #ZZZ '_' + @response.to_s
                             #ZZZ else
                               #ZZZ "Error"
                           #ZZZ end

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
            d.update_attribute(:agree_to_receive_emails, @agree_to_receive_emails)

            #send to iCount instead of email
            #send_ack_email(@xxxEmail, @xxxFirstName + " " + @xxxLastName, @sum.to_s, @donor.currency.name)
            #ZZZ send_to_icount(@donor.name, @donor.country, @donor.email, @donor.sum_dollars,
                           #ZZZ @donor.currency_id, @xxxCCType, @npay.to_i, @first_pay.to_i)
          end
          # Break if @ret_params["Response"][0]
          break
        end
      end
      #ZZZ ssl.close
    end

    if (@response != 0)
      render :layout => "kabcoil"
    else
      render :partial => "thank_you", :layout => false
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
    @rtl = true
    @lang = Localization.lang = "Hebrew"
    @privacy_and_security = url_for(:controller => "user", :action => "window_privacy_and_security")
    @tranzilla = url_for(:protocol => (RAILS_ENV == "production" ? "https://" : "http://"), :controller => "user", :action => "tranzilla")
    @paypal = url_for(:protocol => (RAILS_ENV == "production" ? "https://" : "http://"), :controller => "user", :action => "paypal")
    @bank_details = url_for(:controller => "user", :action => "bank_details")
    @webmoney = url_for(:protocol => (RAILS_ENV == "production" ? "https://" : "http://"), :controller => "user", :action => "webmoney")
    @yandex = url_for(:controller => "user", :action => "yandex")
  end

  def get_page_component(lang, action, suffix)
    page_contents = PageContent.get_page_content_by_lang(lang)
    page_contents.nil? ? '' : page_contents[action + suffix]
  end

  def get_payments(lang)
    Payment.all_payments_by_lang(lang)
  end

    def send_to_icount(name, country, email, sum, currency_id, cc_type, npay = 1, fpay = 0)

    #send to iCount
    comp_id  = "bneibaruch"
    user     = "bb"
    pass     = "an1711"

    doc_type = "receipt"
    income_type_name = (@lang == "Hebrew") ? "Donations" : "DonationsHUL" 
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
    icount_fields = icount_fields + "credit=1&cc_cardtype[0]=#{cc_type}&cctotal[0]=#{sum.to_f}&"
    if npay > 1
      npay = (sum.to_i / fpay.to_f).round()
      icount_fields = icount_fields + "&cc_numofpayments[]=#{npay}&ccfirstpayment[]=#{fpay}&"
    end
    icount_fields = icount_fields + "currency=#{currency_icount}&"
    icount_fields = icount_fields + "lang=#{email_lang}&sendOrig=#{email}"
    #Curl::Easy.http_post("https://www.icount.co.il/api/create_doc_auto.php", icount_fields)
    attempts = 0
    while attempts < 3
      response = RestClient.post("https://www.icount.co.il/api/create_doc_auto.php", icount_fields + '&show_response=1') rescue nil
      sleep 3
      attempts += 1
    end

    #flash[:notice] = c.body_str
  end

end
