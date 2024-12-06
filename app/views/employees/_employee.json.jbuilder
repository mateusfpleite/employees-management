json.extract! employee, :id, :name, :role, :document, :created_at, :updated_at
json.url employee_url(employee, format: :json)
