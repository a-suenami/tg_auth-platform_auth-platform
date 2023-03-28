# typed: false

class SlugValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && value !~ /\A[a-z0-9]+[a-z0-9-]+[a-z0-9]\z/
      record.errors.add(attribute, 'は小文字英字と数字、ハイフンしか使用できません')
    end
  end
end
