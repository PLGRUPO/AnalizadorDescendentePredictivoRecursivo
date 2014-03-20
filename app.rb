require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'slim'
require 'data_mapper'
require 'sinatra/base'
require 'sass'
require 'v8'
require 'coffee-script'

set :public_folder, File.dirname(__FILE__)

# full path!
DataMapper.setup( :default,ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db" )

# Define the model
class User
  include DataMapper::Resource
  
  property :userID, String, :key => true
  property :password, String
  property :email, String
end


class Filo
  include DataMapper::Resource
  
  property :id, Serial
  property :userID, String, :key => true
  property :content, String
end

DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions

@passBuffer = false

helpers do
  def validate(username, password)
    # Put your real validation logic here   
    @usersession = User.new
    @usersession = User.get(username)
    if (@usersession.password == password)
      return username == @usersession.userID;
    else return username == "ERNO"
    end
  end
  
  def is_logged_in?
    session["logged_in"] == true
  end
  
  def is_my_files?
    @passBuffer == true
  end  
  
  def clear_session
    session.clear
  end
  
  def the_user_name
    if is_logged_in? 
      session["username"] 
    else
      "not logged in"
    end
  end
  
  def files_of_user
    if is_my_files?
      if is_logged_in? 
        @Filo_user = Filo.all(:userID => session["username"]) 
      else
        @Filo_user = Filo.all(:userID => "public") 
      end
    else
      @Filo_user = Filo.all(:userID => "public")
    end   
  end
end


get '/style/sass/*.css' do
  filename = params[:splat].first
  scss "../public/style/sass/#{filename}".to_sym
end

get '/scripts/coffee/*.js' do
  filename = params[:splat].first
  coffee "../public/scripts/coffee/#{filename}".to_sym
end

get '/login' do
  slim :login
end

post '/login' do
  if(validate(params["username"], params["password"]))
    session["logged_in"] = true
    session["username"] = params["username"]
    @passBuffer = true
    files_of_user
    # NOTE the right way to do messages like this is to use Rack::Flash
    # https://github.com/nakajima/rack-flash
    @message = "You've been logged in.  Welcome back, #{params["username"]}"
    slim :index, :locals => {
      :c => Filo.new,
      :action => '/files/create'
    }
  else
    puts "error"
    # See note above
    @error_message = "Sorry, those credentials aren't valid."
    slim :login
  end
end

get '/logout' do
  clear_session
  files_of_user
  @message = "You've been logged out."
  slim :index, :locals => {
    :c => Filo.new,
    :action => '/files/create'
  }
end

get '/' do
  files_of_user
  slim :index, :locals => {
    :c => Filo.new,
    :action => '/files/create'
  }
end

post '/files/create' do
  c = Filo.new
  c.content = params["INPUT"]
  if is_logged_in? 
    c.userID = session["username"] 
  else
    c.userID = "public"
  end
  
  if c.save
    redirect("/") 
  end
  # redirect("/files/list")
end

get '/files/list' do
  slim :listFiles, :locals => { :cs => Filo.all }
end


# Show form to create new contact
get '/user/new' do
  slim :form, :locals => {
    :c => User.new,
    :action => '/user/create'
  }
end

# Create new contact
post '/user/create' do
  c = User.new
  c.attributes = params
  #c.save

  #redirect("/user/#{c.userID}")
  if c.save
    redirect("/") 
  end
end

get '/user/:userID' do|userID|
  c = User.get(userID)
  slim :show, :locals => { :c => c }
end

get '/users/' do
  slim :list, :locals => { :cs => User.all }
end

get '/test' do
  slim :test
end
