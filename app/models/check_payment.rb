class CheckPayment < Payment
  validates :check_number, presence: true, allow_blank: false,
                           if: Proc.new { |check| check.success? }

  def authorize
    if payment_method.name == 'terms'
      if account.has_enough_credit
        true
      else
        errors.add(:base, 'Not enough credit for terms payment.') && return
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
    update_columns(refunded: sum)
  end
end
