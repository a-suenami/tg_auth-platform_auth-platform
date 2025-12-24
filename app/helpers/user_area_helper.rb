# frozen_string_literal: true

module UserAreaHelper
  def interval_unit_label(unit)
    case unit
    when 'day' then '日'
    when 'week' then '週'
    when 'month' then 'ヶ月'
    when 'year' then '年'
    else unit
    end
  end

  def payment_method_label(payment_type)
    case payment_type
    when 'credit_card' then 'クレジットカード'
    when 'konbini', 'convenience' then 'コンビニ払い'
    when 'bank_transfer' then '銀行振込'
    else payment_type
    end
  end
end
