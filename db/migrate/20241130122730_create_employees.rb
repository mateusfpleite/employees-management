class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :name
      t.string :document
      t.string :phone_number
      t.string :role

      t.timestamps
    end
  end
end
