class CaseNumberPresenter
  def self.present(c)
    return if c.nil?
    stripped_case_number = c.text_value.delete(' ').delete('.')[1..-1]
    strip_trailing_punctuation(stripped_case_number)
  end

  private

  def self.strip_trailing_punctuation(str)
    new_str = str

    while new_str.end_with?('.', ':')
      new_str = new_str[0..-2]
    end
    new_str
  end
end
