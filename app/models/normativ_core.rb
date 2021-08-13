class NormativCore < ApplicationRecord
  require 'pry'

  has_many :normativ_params
  has_many :naklads, table_name: 'Naklad', foreign_key: 'normativ_id', dependent: :destroy

end
