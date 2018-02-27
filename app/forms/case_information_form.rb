class CaseInformationForm
  include ActiveModel::Model

  def self.from_user(user)
    new.tap do |instance|
      attributes = user.attributes.select { |k, v| ATTRIBUTES.include?(k.to_sym) }
      attributes.each { |k, v| instance.send(:"#{k}=", v)}
    end
  end

  def initialize(attributes = {})
    unless attributes[:on_probation] == 'true'
      attributes.delete(:finished_half_of_probation)
    end
    super(attributes)
  end

  ATTRIBUTES = [
    :on_parole,
    :on_probation,
    :finished_half_of_probation,
    :outstanding_warrant,
    :owe_fees
  ]

  attr_accessor(*ATTRIBUTES)

  ATTRIBUTES.each do |attr|
    validates attr, inclusion: { in: %w(true false), allow_blank: true, message: 'must be true or false' }
  end

  validates :on_parole, presence: true
  validates :on_probation, presence: true
  validates :finished_half_of_probation, presence: true, if: -> () { ['true', true].include?(on_probation) }
  validates :outstanding_warrant, presence: true
  validates :owe_fees, presence: true

  def save(user)
    if valid?
      user.update(Hash[ATTRIBUTES.map { |attribute_name| [attribute_name, send(attribute_name.to_sym)] }])
    end
  end
end
