class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[ show edit update destroy ]

  def index
    # Handle Export
    if request.format.xlsx? && params[:employee_ids].present?
      @employees_to_export = Employee.where(id: params[:employee_ids])
      respond_to do |format|
        format.html
        format.xlsx { render xlsx: "index", filename: "funcionarios.xlsx" }
      end
      return
    end

    if params[:search] && (params[:search][:name].present? || params[:search][:role].present?)
      name_to_lower = remove_special_characters(params[:search][:name].downcase)
      @employees = Employee.where("unaccent(LOWER(name)) LIKE ?", "%#{name_to_lower}%")
      role_to_lower = remove_special_characters(params[:search][:role].downcase)
      @employees = @employees.where("role @> ARRAY[?]::varchar[]", [role_to_lower]) if role_to_lower.present?

    else
      @employees = Employee.all
    end
    @employees = @employees.order(:name)
  end

  def remove_special_characters(string)
    I18n.transliterate(string).strip
  end

  def show; end
  def new; @employee = Employee.new; end
  def edit; end

  def create
    @employee = Employee.new(employee_params)
    if @employee.save
      redirect_to @employee, notice: "Employee was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @employee.update(employee_params)
      redirect_to @employee, notice: "Employee was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy!
    redirect_to employees_path, status: :see_other, notice: "Employee was successfully destroyed."
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee).permit(:name, :role, :document)
  end
end
