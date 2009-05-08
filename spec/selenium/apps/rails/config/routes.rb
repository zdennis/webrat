ActionController::Routing::Routes.draw do |map|
  # catch-all route
  map.connect '*path', :controller => 'webrat', :action => 'index'
end
