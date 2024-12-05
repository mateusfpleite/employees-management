require 'csv'

folder_path = "/home/mateus/Downloads/planilhas_csv"

all_employees = []


def row_to_employee(row)
  employee = {}
  row.each do |header, value|
    case header
    when "NOME"
      employee["name"] = remove_special_characters(value)
    when "DOC."
      employee["document"] = value ? value.gsub(/[^0-9]/, '').strip : nil
    when "FUNÇÃO"
      employee["role"] = value ? [ value.strip.downcase ] : []
    end
  end
  employee
end


def remove_special_characters(string)
  string_without_accents = I18n.transliterate(string).strip;
  # string_without_accents.gsub(/[^0-9a-z ]/i, '').strip
  string_without_accents
end

def add_employee_role_if_not_exists(employee, role)
  employee["role"] << role.strip.downcase unless employee["role"].include?(role.strip.downcase)
end

# Iterate through each file in the folder
Dir.glob("#{folder_path}/*.csv").each do |file_path|
  puts "Reading file: #{file_path}"

  # Read the CSV file with normalized headers
  cachorro = CSV.read(file_path, headers: true, header_converters: ->(header) { header.strip })

  employees = cachorro.reduce([]) do |acc, row|
    # if employee already exists, add current role to roles array
    existing_employee = all_employees.find { |employee| employee["name"] == row["NOME"] }
    if existing_employee
      add_employee_role_if_not_exists(existing_employee, row["FUNÇÃO"])
      next acc
    end

    row["NOME"] ? acc << row_to_employee(row) : acc
  end

  all_employees += employees
end

unique_employees = all_employees.uniq { |employee| [ employee["name"], employee["document"] ] }


# add employees to database using the Employee model

unique_employees.each do |employee|
  new_employee = Employee.create!(name: employee["name"], document: employee["document"], role: employee["role"])
  new_employee.save
end
