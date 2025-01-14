require 'csv'

folder_path = "/home/mateus/Downloads/planilhas_csv"

all_employees = []

def normalize_role(role)
  base_role = role.downcase.strip
  if base_role.include?("coord")
    base_role = base_role.gsub(/\bcoord\.?\b/i, "coordenador").gsub('.', '')
  end
  if base_role.include?("aux")
    base_role = base_role.gsub(/\baux\.?\b/i, "auxiliar")
  end
  if base_role.include?("louge")
    base_role = base_role.gsub(/louge/, "lounge")
  end
  base_role
end


def row_to_employee(row, file_path)
  employee = {}
  row.each do |header, value|
    case header
    when "NOME"
      employee["name"] = value.strip.upcase
    when "DOC."
      employee["document"] = value ? value.gsub(/[^0-9]/, '').strip : nil
    when "FUNÇÃO"
      employee["role"] = value ? [ normalize_role(value) ] : []
    end
  end
  employee["file"] = file_path.split("/").last
  employee
end


def add_employee_role_if_not_exists(employee, role)
  employee["role"] << normalize_role(role) unless employee["role"].include?(normalize_role(role))
end

# Iterate through each file in the folder
Dir.glob("#{folder_path}/*.csv").each do |file_path|
  puts "Reading file: #{file_path}"

  # Read the CSV file with normalized headers
  file_content = CSV.read(file_path, headers: true, header_converters: ->(header) { header.strip })

  employees = file_content.reduce([]) do |acc, row|
    # if employee already exists, add current role to roles array
    existing_employee = all_employees.find { |employee| employee["name"] == row["NOME"] }
    if existing_employee
      add_employee_role_if_not_exists(existing_employee, row["FUNÇÃO"])
      next acc
    end

    row["NOME"] ? acc << row_to_employee(row, file_path) : acc
  end

  all_employees += employees
end

unique_employees = all_employees.uniq { |employee| [ employee["name"].downcase, employee["document"] ] }


# add employees to database using the Employee model

unique_employees.each do |employee|
  new_employee = Employee.create!(name: employee["name"], document: employee["document"], role: employee["role"], file: employee["file"])
  new_employee.save
end

