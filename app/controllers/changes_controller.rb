class ChangesController < ApplicationController

  def index
    @changes_html = Kramdown::Document.new(File.read("#{Rails.root}/CHANGES.md")).to_html
  end


  private

  def allow?(user)
    user.is_admin?
  end

end
