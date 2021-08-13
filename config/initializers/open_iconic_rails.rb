module OpenIconicRails
  class Engine < ::Rails::Engine
    Rails.application.config.assets.precompile += %w( open-iconic.min.svg )
  end
end