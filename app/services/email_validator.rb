class EmailValidator
  def initialize(email)
    @email = email
  end

  def valid?
    email.match?(URI::MailTo::EMAIL_REGEXP)
  end

  private

    attr_reader :email
end
