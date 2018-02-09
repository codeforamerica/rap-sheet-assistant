class CountPresenter
  def self.present(count)
    {
        penal_code: format_penal_code(count),
        penal_code_description: format_penal_code_description(count)
    }
  end

  private

  def self.format_penal_code(count)
    if count.penal_code
      "#{count.penal_code.code.text_value} #{count.penal_code.number.text_value.rstrip}"
    else
      #check comments for charge
    end
  end

  def self.format_penal_code_description(count)
    if count.penal_code_description
      count.penal_code_description.text_value.chomp
    else
      #check comments for charge
    end
  end
end
