require 'csv'
require 'axlsx'
require 'creek'

module ContactsHelper
  def generate_csv data
    csv_data = CSV.generate do |csv|
      csv << data[:headers]
      data[:rows].each do |row|
        csv << row
      end
    end

    return csv_data
  end

  def generate_xlsx data
    widths = []
    (data[:headers].length).times do
      widths << 16
    end

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => 'Contacts') do |sheet|
        sheet.add_row data[:headers], widths: widths
        data[:rows].each do |row|
          sheet.add_row row, widths: widths
        end
      end
      p.serialize(Rails.root.join('private', 'contacts_import', "xlsx_template_#{current_user.id}.xlsx"))
    end
  end

  def get_contacts_template_data
    metadata = current_user.metadata

    extra_placeholders = []
    metadata.length.times do
      extra_placeholders << ' '
    end

    groups = 'new_group'

    real_group = ContactGroup.find_by(uid: current_user.id)
    groups = real_group[:label] + '/' + groups unless real_group.blank?

    headers = %w(prefix mobile).concat(metadata).push('groups')
    example = %w(44 1234567890).concat(extra_placeholders).push(groups)

    return { headers: headers, rows: [example] }
  end

  def parse_contacts filetype
    if Rails.configuration.x.csv.include? filetype
      contacts = csv_rows params[:contact][:contact_lists].tempfile
    elsif Rails.configuration.x.xlsx.include? filetype
      contacts = xlsx_rows params[:contact][:contact_lists].tempfile
    end

    return contacts
  end

  def csv_rows file
    rows = []

    File.open(file, 'r') do |f|
      tmp_rows = f.read.split(/\r?\n/)
      arr_of_arrs = tmp_rows.collect { |row| row.split(',') }

      headers = arr_of_arrs.shift

      mandatory_headers = mandatory_headers headers
      unless mandatory_headers[:labels].blank?
        mandatory_headers[:missing] = true
        return mandatory_headers
      end

      invalid_headers = invalid_headers headers
      unless invalid_headers[:labels].blank?
        invalid_headers[:invalid] = true
        return invalid_headers
      end

      arr_of_arrs.each do |row|
        i = 0
        row_hash = {}
        headers.each do |header|
          row_hash[header] = row[i]
          i += 1
        end
        rows << row_hash
      end
    end

    return rows
  end

  def xlsx_rows file
    rows = []

    creek = Creek::Book.new file.path
    sheet = creek.sheets[0]

    headers = sheet.rows.first.values

    missing_headers = mandatory_headers headers
    unless missing_headers[:labels].blank?
      missing_headers[:missing] = true
      return missing_headers
    end

    invalid_headers = invalid_headers headers
    unless invalid_headers[:labels].blank?
      invalid_headers[:invalid] = true
      return invalid_headers
    end

    sheet.rows.each do |row_hash|
      row = row_hash.values
      i = 0
      row_hash = {}
      headers.each do |header|
        row_hash[header] = row[i]
        i += 1
      end
      rows << row_hash
    end

    rows.shift

    return rows
  end

  def mandatory_headers headers
    mandatory_headers = ['prefix', 'mobile']
    missing_headers = { labels: [] }

    mandatory_headers.each do |mandatory|
      unless headers.include? mandatory
        missing_headers[:labels] << mandatory
      end
    end

    return missing_headers
  end

  def invalid_headers headers
    default_headers = ['prefix', 'mobile', 'first_name', 'last_name', 'groups']
    invalid_headers = { labels: [] }

    headers.each do |header|
      unless (default_headers.include? header or current_user.metadata.include? header)
        invalid_headers[:labels] << header
      end
    end

    return invalid_headers
  end
end
