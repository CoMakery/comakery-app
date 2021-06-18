class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def save_if_no_errors
    return false if errors.any?

    save
  end

  def update_if_no_errors(params)
    assign_attributes(params)
    return false if errors.any?

    save
  end
end
