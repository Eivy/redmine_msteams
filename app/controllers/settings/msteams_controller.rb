class Settings::MsteamsController < ApplicationController
  def test
    Msteams::Msteams.post("this is test from redmine", [User.current])
    redirect_to request.referer
  end
end
