#--
# Copyright (c) 2005 Tobias Luetke
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
                    
$:.unshift(File.dirname(__FILE__))      

# Include rails' active support for all the core extensions we love
begin
  require 'active_support'
rescue LoadError
  require 'rubygems'
  require 'activesupport'
end

begin
  require 'builder'
rescue LoadError
  require 'rubygems'
  require 'builder'
end

require 'cgi'

require 'active_merchant/lib/validateable'
require 'active_merchant/lib/posts_data'
require 'active_merchant/lib/post_data'
require 'active_merchant/lib/requires_parameters'

# Require the country class
require 'active_merchant/lib/country'

# CreditCard Utility class. 
require 'active_merchant/billing/credit_card_methods'
require 'active_merchant/billing/credit_card_formatting'
require 'active_merchant/billing/credit_card'

require 'active_merchant/billing/base'

# Require the supported gateways
require 'active_merchant/billing/gateways'

# Require the supported integrations
require 'active_merchant/billing/integrations'
