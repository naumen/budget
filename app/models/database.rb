# Model Database
class Database < ApplicationRecord
  def self.development!
    ActiveRecord::Base.establish_connection(:development)
  end

  def self.snapshot!
    ActiveRecord::Base.establish_connection(:'snapshot')
  end
  #
  # def self.staging!
  #   ActiveRecord::Base.establish_connection(ENV['STAGING_DATABASE'])
  # end
end