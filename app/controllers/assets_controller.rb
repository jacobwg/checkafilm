class AssetsController < ApplicationController

  caches_action :tmdb

  def tmdb
    i = Curl.get("http://cf2.imgobject.com/t/p/#{params[:size]}/#{params[:path]}.jpg")
    send_data i.body_str, :filename => params[:path], :type => i.content_type, :disposition => 'inline'
  end
end
