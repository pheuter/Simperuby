require 'rest_client'
require 'json'

class Simperuby  
  attr_accessor :access_token
  
  def initialize(params={})
    if params[:app_id]
      @app_id = params[:app_id]
    else
      raise 'You need to provide an :app_id'
    end
    if params[:api_key]
      @api_key = params[:api_key]
    else
      raise 'You need to provide an :api_key'
    end
  end
  
  def create(user,pass)
    res = JSON.parse RestClient.post "https://auth.simperium.com/1/#{@app_id}/create/", { 'username' => user, 'password' => pass }.to_json, { 'X-Simperium-API-Key' => @api_key }
    @access_token = res['access_token']
    res
  end
  
  def authorize(user,pass)
    res = JSON.parse RestClient.post "https://auth.simperium.com/1/#{@app_id}/authorize/", { 'username' => user, 'password' => pass }.to_json, { 'X-Simperium-API-Key' => @api_key }
    @access_token = res['access_token']
    res
  end
  
  def [](name)
    if @access_token
      Bucket.new @app_id, @access_token, name
    else
      raise "You need to authorize client first, try authorize(user,pass)"
    end
  end
end

class Bucket
  attr_accessor :name
  
  def initialize(app_id, access_token, name)
    @app_id = app_id
    @access_token = access_token
    @name = name
  end
  
  def index(params={})
    JSON.parse RestClient.get "https://api.simperium.com/1/#{@app_id}/#{@name}/index", :params => { :data => params[:data], :mark => params[:mark], :limit => params[:limit], :since => params[:since] }, 'X-Simperium-Token' => @access_token
  end
  
  def new(data)  
    uid = (1..32).map{([*('a'..'z')]+[*('A'..'Z')]+[*(1..9)].map{|n|n.to_s}).instance_eval{self[rand(self.size)]}}.join
    RestClient.post "https://api.simperium.com/1/#{@app_id}/#{@name}/i/#{uid}", data.to_json, { 'X-Simperium-Token' => @access_token }
    uid
  end
  
  def [](object_id)
    JSON.parse RestClient.get "https://api.simperium.com/1/#{@app_id}/#{@name}/i/#{object_id}", { 'X-Simperium-Token' => @access_token }
  end
  
  def []=(object_id, data)
   JSON.parse RestClient.post "https://api.simperium.com/1/#{@app_id}/#{@name}/i/#{object_id}?response=1", data.to_json, { 'X-Simperium-Token' => @access_token }
  end
  
  def delete(object_id)
    RestClient.delete "https://api.simperium.com/1/#{@app_id}/#{@name}/i/#{object_id}", { 'X-Simperium-Token' => @access_token }
  end
  
  def changes(params={})
    JSON.parse RestClient.get "https://api.simperium.com/1/#{@app_id}/#{@name}/all", :params => { :cv => params[:cv], :data => params[:data], :username => params[:username] }, 'X-Simperium-Token' => @access_token
  end
end