class SentencePresenter
  def self.present(sentence)
    return unless sentence

    parts = sentence.text_value.
      downcase.
      gsub(/[.']/, '').
      gsub(/\n\s*/, ' ').
      split(', ')

    parts.map do |p|
      p.gsub(/(\d+) (months|years|days)/) do |match|
        words = match.split(' ')
        "#{words[0].to_i}#{words[1][0]}"
      end.gsub(/(restn|rstn)/, 'restitution')
    end.join(', ')
  end
end
