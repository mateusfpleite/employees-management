class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :role, array: true, default: []
      t.string :document
      t.string :file

      t.timestamps
    end
  end
end
