class Prop47PetitionCreator
  include PetitionCreator

  def initialize(rap_sheet:, conviction_event:, conviction_counts:, remedy_details:)
    @rap_sheet = rap_sheet
    @conviction_event = conviction_event
    @conviction_counts = conviction_counts
    @remedy_details = remedy_details
  end

  def create_petition
    user = rap_sheet.user
    if user.has_attorney
      attorney = user.attorney
      contact_info_person = attorney
      client_name = user.name
      state_bar_number = "State Bar No. #{attorney.state_bar_number}"
    else
      contact_info_person = user
      client_name = 'PRO-SE'
      state_bar_number = ''
    end
    pdf_fields = {
      'attorney_name' => contact_info_person.name,
      'attorney_state_bar_number' => state_bar_number,
      'attorney_street_address' => contact_info_person.street_address,
      'attorney_city_state_zip' => formatted_city_state_zip(contact_info_person),
      'attorney_phone' => contact_info_person.phone_number,
      'attorney_fax' => '',
      'client_name' => client_name,
      'county' => conviction_event.courthouse,
      'defendant' => user.name,
      'case_number' => conviction_event.case_number,
      'conviction_date' => formatted_conviction_date,
      'code_sections' => code_sections,
      'sentence' => conviction_event.sentence.to_s
    }


      pdf_fields.merge!(checkboxes)

      fill_petition('prop47_petition.pdf', pdf_fields)
    end

    private

    def formatted_conviction_date
      conviction_event.date.strftime('%m/%d/%Y')
    end

    attr_reader :rap_sheet, :conviction_event, :conviction_counts, :remedy_details

    def formatted_city_state_zip(user)
      "#{user.city}, #{user.state}  #{user.zip}"
    end


    def code_sections
      conviction_counts.map(&:code_section).join(', ')
    end

    def checkboxes
      if remedy_details[:scenario] == 'redesignation'
        {
          'reduction_checkbox' => 'Yes',
          'reduction_checkbox_2' => 'Yes',
          'reduction_checkbox_3' => 'Yes'
        }
      elsif remedy_details[:scenario] == 'resentencing'
        {
          'resentencing_checkbox' => 'Yes',
          'resentencing_checkbox_2' => 'Yes',
          'resentencing_checkbox_3' => 'Yes'
        }
      else
        {}
      end
    end
  end
