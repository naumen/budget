# Model Document
class Document < ActiveRecord::Base
  belongs_to :investment_project, foreign_key: 'investment_project_id', optional: true
  belongs_to :invest_loan, foreign_key: 'invest_loan_id', optional: true
  belongs_to :owner, polymorphic: true, optional: true

  #validate :file_size_under_one_mb

  def archive!
    self.archived_at = Time.now
    self.save
  end

  def self.store_file(params, owner=nil)
    d = Document.new
    d.owner = owner if owner
    d.save
    @file = params.delete(:file)

    d.original_file_name = File.basename(@file.original_filename)
    d.filename           = get_filename(d, @file.original_filename)
    d.content_type       = @file.content_type
    d.save
    self.save_file(d.filename, @file)
    d.id
  end

  def file_content
    File.read(Rails.root.join('public','docs', filename))
  end


private
  def self.save_file(file_name, file)
    path_on_filesystem = Rails.root.join('public','docs', file_name)
    File.open(path_on_filesystem,'wb') do |f|
      f.write(file.read)
    end
  end

  def self.get_filename(doc, filename)
    return "#{"%03d" % doc.id}_#{escaped_file_name(File.basename(filename))}"
  end

  def self.escaped_file_name(filename)
    els = filename.split('.')
    ext = els.pop
    self.sanitize(els.join('.')) + '.' + ext
  end

  def self.sanitize(filename)
    # Bad as defined by wikipedia: https://en.wikipedia.org/wiki/Filename#Reserved_characters_and_words
    # Also have to escape the backslash
    bad_chars = [ '/', '\\', '?', '%', '*', ':', '|', '"', '<', '>', '.', ' ' ]
    bad_chars.each do |bad_char|
    filename.gsub!(bad_char, '_')
    end
    filename
  end

  NUM_BYTES_IN_MEGABYTE = 1048576
  def file_size_under_one_mb
    if (@file.size.to_f / NUM_BYTES_IN_MEGABYTE) > 50
      errors.add(:file, 'File size cannot be over 50 megabyte.')
    end
  end
end
