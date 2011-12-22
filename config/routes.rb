ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  map.connect 'kabcoil/:action', :controller => 'kabcoil'

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  #map.from_plugin :simple_pages
  #map.connect ':lang/:controller/:action/:id.:format'
  map.connect ':lang/:controller/:action/:id', :defaults => { :lang => 'English', :controller => 'user', :action => 'index', :id => '0' }
  #map.empty '', :lang => 'English', :controller => 'user', :action => 'index'
end
