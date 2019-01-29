class ContactInformationForm
  include ActiveModel::Model

  def self.from_user(user)
    new.tap do |instance|
      attributes = user.attributes.select { |k, v| ATTRIBUTES.include?(k.to_sym) }
      attributes.each { |k, v| instance.send(:"#{k}=", v)}
    end
  end

  def initialize(attributes = {})
    year = attributes['date_of_birth(1i)']
    month = attributes['date_of_birth(2i)']
    day = attributes['date_of_birth(3i)']
    if [year, month, day].all?(&:present?)
      self.date_of_birth = Date.new(year.to_i, month.to_i, day.to_i)
    end
    super(attributes.reject { |k, v| k.match(/date_of_birth/) })
  end

  ATTRIBUTES = [
    :name,
    :phone_number,
    :email,
    :street_address,
    :city,
    :state,
    :zip,
    :date_of_birth,
    :prefer_email,
    :prefer_text
  ]

  attr_accessor(*ATTRIBUTES)

  # validates :name, presence: true
  # validates :phone_number, presence: true
  # validates :email, presence: true
  # validates :street_address, presence: true
  # validates :city, presence: true
  # validates :state, presence: true
  # validates :zip, presence: true
  # validates :date_of_birth, presence: true
  # validates :preferred_contact_method, presence: true

  def save(user)
    if valid?
      user.update(Hash[ATTRIBUTES.map { |attribute_name| [attribute_name, send(attribute_name.to_sym)] }])
    end
  end
end
