class ExpenditurePolicy < ApplicationPolicy
  def manage?
    user_is_admin?
  end
end
