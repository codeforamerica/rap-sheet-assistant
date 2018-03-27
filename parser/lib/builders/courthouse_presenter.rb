class CourthousePresenter
  def self.present(courthouse)
    courthouse_names = {
        'CASC SAN FRANCISCO' => 'CASC San Francisco',
        'CAMC RICHMOND' => 'CAMC Richmond',
        'CASC MCRICHMOND' => 'CASC Richmond',
        'CAMC CONCORD' => 'CAMC Concord',
        'CASC CONCORD' => 'CASC Concord',
        'CASC CONTRA COSTA' => 'CASC Contra Costa',
        'CASC PITTSBURG' => 'CASC Pittsburg',
        'CASC PLACER' => 'CASC Placer',
        'CASC WALNUT CREEK' => 'CASC Walnut Creek',
        'CASC MCSAN RAFAEL' => 'CASC MC San Rafael',
        'CASC MCOAKLAND' => 'CASC MC Oakland',
        'CAMC HAYWARD' => 'CAMC Hayward',
        'CASC MCSACRAMENTO' => 'CASC MC Sacramento',
        'CASC SN JOSE' => 'CASC San Jose',
        'CAMC LOS ANGELES METRO' => 'CAMC Los Angeles Metro',
        'CASC LOS ANGELES' => 'CASC Los Angeles'
    }

    courthouse_text = courthouse.text_value.gsub('.', '').upcase

    if courthouse_names.key?(courthouse_text)
      courthouse_names[courthouse_text]
    else
      courthouse_text
    end
  end
end
