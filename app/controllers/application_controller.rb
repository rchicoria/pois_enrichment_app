class ApplicationController < ActionController::Base
  protect_from_forgery

  def mobile_agent?
  	# negate this statement to test for mobile
	(request.user_agent =~ /Mobile|webOS/ and not request.user_agent =~ /iPad/)
  end
end
