require 'rubygems'
require 'sinatra'
require 'bcrypt'
require 'haml'
require 'data_mapper'
require 'sinatra/base'


set :public_folder, File.dirname(__FILE__)

# full path!
DataMapper.setup( :default, "sqlite3://#{Dir.pwd}/database.db" )

# Define the model
class User
  include DataMapper::Resource
  
  property :userID, String, :key => true
  property :email, String
end


class Filo
  include DataMapper::Resource
  
   property :id, Serial
   property :content, String
end

  DataMapper.finalize
  DataMapper.auto_upgrade!

enable :sessions


helpers do
  def validate(username, password)
    # Put your real validation logic here
    usersession = User.new
    usersession = User.get(username)
    return username == usersession.firstname;
  end
  
  def is_logged_in?
    session["logged_in"] == true
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
end

get '/login' do
  haml :login
end

post '/login' do
  if(validate(params["username"], params["password"]))
    session["logged_in"] = true
    session["username"] = params["username"]
    # NOTE the right way to do messages like this is to use Rack::Flash
    # https://github.com/nakajima/rack-flash
    @message = "You've been logged in.  Welcome back, #{params["username"]}"
    haml :index
  else
    puts "error"
    # See note above
    @error_message = "Sorry, those credentials aren't valid."
    haml :login
  end
end

get '/logout' do
  clear_session
  @message = "You've been logged out."
  haml :index
end



get '/' do
  haml :index, :locals => {
    :c => Filo.new,
    :action => '/files/create'
  }
end

post '/files/create' do
  c = Filo.new
  c.content = params["INPUT"]
  c.save
  redirect("/files/list")
end

get '/files/list' do
  haml :listFiles, :locals => { :cs => Filo.all }
end


# Show form to create new contact
get '/user/new' do
  haml :form, :locals => {
    :c => User.new,
    :action => '/user/create'
  }
end

# Create new contact
post '/user/create' do
  c = User.new
  c.attributes = params
  c.save

  redirect("/user/#{c.id}")
end

get '/user/:id' do|id|
  c = User.get(id)
  haml :show, :locals => { :c => c }
end

get '/users/' do
  haml :list, :locals => { :cs => User.all }
end

__END__


@@ listFiles
%h1 Files
%table
  - cs.each do|c|
    %tr
      %td= c.content

