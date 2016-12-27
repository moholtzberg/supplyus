class ApiController < ApplicationController
  acts_as_token_authentication_handler_for User
  before_action :authenticate_user!
  protect_from_forgery with: :null_session
end