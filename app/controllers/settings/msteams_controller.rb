require File.expand_path('../../../../lib/redmine_msteams/msteams', __FILE__)
class Settings::MsteamsController < ApplicationController
  def test
    RedmineMsteams::Msteams::Msteams::post("this is test from redmine", [User.current])
    redirect_to request.referer
  end
end
