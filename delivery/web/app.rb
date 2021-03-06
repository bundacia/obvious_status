require 'sinatra'
require 'slim'
require 'sequel'

require_relative '../../app/actions/list_statuses'
require_relative '../../app/actions/create_status'
require_relative '../../app/actions/get_status'
require_relative '../../app/actions/update_status'
require_relative '../../app/actions/remove_status'

require_relative '../../app/actions/get_user'
require_relative '../../app/actions/list_users'
require_relative '../../app/actions/create_user'

require_relative '../../external/status_jack'
require_relative '../../external/user_jack'

set :slim, :pretty => true

DB = Sequel.connect 'mysql://127.0.0.1:3306/status?user=root' # this should probably be set as an environment variable
 
MONGO_SESSION = Moped::Session.new ['127.0.0.1:27017'] 
MONGO_SESSION.use 'status' 

get '/' do
  # get list of statuses 
  action = ListStatuses.new StatusJack.new
  @statuses = action.execute

  # get list of users
  action = ListUsers.new UserJack.new
  users = action.execute
  @users = {}
  users.each do |user|
    @users[user[:id]] = user
  end

  slim :index
end

get '/:user/create-status' do
  slim :create_status
end

post '/:user/create-status' do
  input = { :user_id => params[:user_id].to_i, :text => params[:text] }
  action = CreateStatus.new StatusJack.new
  @status = action.execute input
  redirect '/'
end

get '/sign-up' do
  slim :sign_up
end

post '/sign-up' do
  input = { :handle => params[:handle] }
  action = CreateUser.new UserJack.new
  @user = action.execute input
  redirect "/user/#{@user[:id]}"
end

get '/user/:id' do
  input = { :id => params[:id].to_i }
  action = GetUser.new UserJack.new
  @user = action.execute input
  slim :get_user
end

get '/status/:id' do
  input = { :id => params[:id].to_i }
  action = GetStatus.new StatusJack.new
  @status = action.execute input

  input = { :id => @status[:user_id] }
  action = GetUser.new UserJack.new
  @user = action.execute input
  slim :get_status
end

get '/status/:id/update' do
  input = { :id => params[:id].to_i }
  action = GetStatus.new StatusJack.new
  @status = action.execute input
  slim :update_status
end

post '/status/:id/update' do
  input = { :id => params[:id].to_i, :text => params[:text], :user_id => params[:user_id].to_i }
  action = UpdateStatus.new StatusJack.new
  @status = action.execute input
  redirect "/status/#{@status[:id]}" 
end

get '/status/:id/remove' do
  input = { :id => params[:id].to_i }
  action = GetStatus.new StatusJack.new
  @status = action.execute input
 
  input = { :id => @status[:user_id] }
  action = GetUser.new UserJack.new
  @user = action.execute input
  slim :remove_status
end

post '/status/:id/remove' do
  input = { :id => params[:id].to_i }
  action = RemoveStatus.new StatusJack.new
  result = action.execute input
  if result == true
    redirect '/'
  else
    'ERROR'
  end 
end
