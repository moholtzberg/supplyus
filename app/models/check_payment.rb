class CheckPayment < Payment
  validates :check_number, presence: true, allow_blank: false,
                           if: Proc.new { |check| check.success? }

  def authorize
    if payment_method.name == 'terms'
      if account.has_credit
        true
      else
        errors.add(:base, 'Youre account is either on hold or has insufficient credit available to process this order.') && return
        false
      end
    elsif payment_method.name == 'check'
      true
    end
  end

  def capture
    self.success = true
    save
  end

  def refund(sum)
    puts "reeeeeefunuuuuuund #{sum}"
    update_attributes(refunded: sum)
  end

  def authorized?
    true
  end
end
