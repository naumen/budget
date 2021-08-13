class Snapshot < ApplicationRecord
  def self.create_dump(filename)
    system "rake db:dump > db/backups/#{filename}"
  end

  def self.restore_from_dump(filename, username='budget', password='password', db_name='snapshot')
    system "mysql -u #{username} -p#{password} -D #{db_name} < #{filename}"
  end
end
