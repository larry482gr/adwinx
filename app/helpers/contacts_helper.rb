require 'CSV'
require 'axlsx'

module ContactsHelper
  def generate_csv_template
    data = get_template_data
    csv_data = CSV.generate(encoding: 'UTF-8') do |csv|
      csv << data[:headers]
      csv << data[:row]
    end

    return csv_data
  end

  def generate_xlsx_template
    data = get_template_data

    widths = []
    (data[:headers].length).times do
      widths << 20
    end

    Axlsx::Package.new do |p|
      p.workbook.add_worksheet(:name => 'Contacts') do |sheet|
        sheet.add_row data[:headers], widths: widths
        sheet.add_row data[:row], widths: widths
      end
      p.serialize('xlsx_template.xlsx')
    end
  end

  def get_template_data
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

    return { headers: headers, row: example }
  end
end
