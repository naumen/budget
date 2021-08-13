# Model ApplicationRecord

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.get_rows_by_url(url)
    require 'open-uri'
    cnt = open(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
    return self.parse_plain_content(cnt)
  end

  # преобразовывает текст (с заголовком из названий полей) и строк в массив хэшей
  def self.parse_plain_content(cnt)
    rows = []
    delimiter = "\t"
    fields = nil
    cnt.readlines.each do |line|
      line.chomp!
      next if line.blank?
      els = line.split(delimiter)
      if fields.nil?
        fields = els
        next
      end

      row_hash = {}
      pos = 0
      fields.each do |f_name|
        val = els[pos]
        row_hash[f_name] = val
        pos += 1
      end
      rows << row_hash
    end
    return rows
  end

end
