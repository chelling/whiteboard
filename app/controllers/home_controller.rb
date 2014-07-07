class HomeController < ApplicationController
  def index
    @header_title = "Welcome"
    @mobile_header = "FOO-NATION"
    @year = Date.today.year
  end
end
