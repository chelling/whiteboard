class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :prepare_for_mobile

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  private

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] unless params[:mobile].nil?
    request.format = :mobile if mobile_device?
  end

  def require_login
    if !user_signed_in?
      return redirect_to "/users/sign_in"
    end
  end
end
