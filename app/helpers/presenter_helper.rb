module PresenterHelper

  def depositor?(presenter, user)
    presenter.depositor == user.user_key
  end

end
