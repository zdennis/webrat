class WebratController < ApplicationController
  def index
    render :text => params.except(:action, :controller, :path).to_json
  end
end