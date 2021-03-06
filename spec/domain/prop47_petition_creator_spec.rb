require 'rails_helper'

RSpec.describe Prop47PetitionCreator do
  let(:has_attorney) { false }
  let(:user) do
    create(:user,
           name: 'John Felix Brown',
           date_of_birth: Date.parse('1970-01-01'),
           street_address: '123 Fake St',
           city: 'San Francisco',
           state: 'CA',
           zip: '12345',
           phone_number: '000-111-2222',
           email: 'me@me.com',
           has_attorney: has_attorney
    )
  end

  let(:conviction_counts) do
    [
      build_count(
        dispositions: [build_disposition(sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year), severity: 'F', date: Date.new(2010,1,1))],
        code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
        code: 'PC',
        section: '484'
      ),
      build_count(
        dispositions: [build_disposition(sentence: RapSheetParser::ConvictionSentence.new(probation: 1.year), severity: 'F', date: Date.new(2010,1,1))],
        code_section_description: 'RECEIVE/ETC KNOWN STOLEN PROPERTY',
        code: 'PC',
        section: '487d'
      )
    ]
  end
  let (:conviction_event) do
    build_court_event(
      case_number: '#ABCDE',
      date: Date.new(2010, 1, 1),
      courthouse: 'CASC SAN FRANCISCO',
      counts: conviction_counts
    )
  end

  let(:remedy_details) { { scenario: :redesignation } }

  let(:pdf_file) do
    Prop47PetitionCreator.new(
      rap_sheet: rap_sheet,
      conviction_event: conviction_event,
      conviction_counts: conviction_counts,
      remedy_details: remedy_details
    ).create_petition
  end

  let(:rap_sheet) { create(:rap_sheet, user: user) }

  describe 'contact info fields' do
    context 'when the client has an attorney' do
      let(:has_attorney) { true }
      let(:attorney) do
        create(:attorney,
               name: 'Ms. Attorney',
               state_bar_number: '1234567',
               firm_name: 'The Firm',
               street_address: '555 Main Street',
               city: 'Tulsa',
               state: 'OK',
               zip: '55555',
               phone_number: '5555555555',
               email: 'email@example.com'
        )
      end

      before do
        user.update(attorney: attorney)
      end

      it 'creates a filled-out form with the attorney info' do
        expected_values = {
          'attorney_name' => 'Ms. Attorney',
          'attorney_state_bar_number' => 'State Bar No. 1234567',
          'attorney_street_address' => '555 Main Street',
          'attorney_city_state_zip' => 'Tulsa, OK  55555',
          'attorney_phone' => '5555555555',
          'attorney_fax' => '',
          'client_name' => 'John Felix Brown',
          'defendant' => 'John Felix Brown'
        }
        expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
      end

      it 'adds a proof a service form' do
        expected_proof_of_service_values = {
          'name' =>'Ms. Attorney',
          'state bar number' =>'State Bar No. 1234567',
          'firm name' =>'The Firm',
          'proof_of_service_prop47' => 'Yes',
          'street address' =>'555 Main Street',
          'city' =>'Tulsa',
          'state' =>'OK',
          'zip' =>'55555',
          'phone number' =>'5555555555',
          'email' =>'email@example.com',
          'attorney for' =>'John Felix Brown',
          'defendant' =>'John Felix Brown',
          'case number' =>'#ABCDE'
        }

        expect(get_fields_from_pdf(pdf_file)).to include(expected_proof_of_service_values)
      end

      context 'attorney info is mission' do
        let(:attorney) do
          create(:attorney,
                 name: 'Ms. Attorney',
                 state_bar_number: '',
                 firm_name: 'The Firm',
                 street_address: '555 Main Street',
                 city: 'Tulsa',
                 state: '',
                 zip: '12345',
                 phone_number: '5555555555',
                 email: 'email@example.com'
                )
        end

        it 'does not fill blank sb numbers or address info' do
          expected_values = {
            'attorney_name' => 'Ms. Attorney',
            'attorney_state_bar_number' => '',
            'attorney_street_address' => '555 Main Street',
            'attorney_city_state_zip' => '',
            'attorney_phone' => '5555555555',
            'attorney_fax' => '',
            'client_name' => 'John Felix Brown',
            'defendant' => 'John Felix Brown'
          }
          expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
        end
      end
    end

    context 'when the client is filing pro se' do
      it 'creates a filled-out form with client info' do
        expected_values = {
          'attorney_name' => 'John Felix Brown',
          'attorney_state_bar_number' => '',
          'attorney_street_address' => '123 Fake St',
          'attorney_city_state_zip' => 'San Francisco, CA  12345',
          'attorney_phone' => '000-111-2222',
          'attorney_fax' => '',
          'client_name' => 'PRO-SE',
          'defendant' => 'John Felix Brown'
        }
        expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
      end

      it 'creates a filled out proof of service with client info' do
        expected_proof_of_service_values = {
          'name' =>'John Felix Brown',
          'state bar number' =>'',
          'firm name' =>'',
          'street address' =>'123 Fake St',
          'city' =>'San Francisco',
          'state' =>'CA',
          'zip' =>'12345',
          'phone number' =>'000-111-2222',
          'email' =>'me@me.com',
          'defendant' =>'John Felix Brown',
          'attorney for' =>'PRO-SE',
          'case number' =>'#ABCDE'
        }
        expect(get_fields_from_pdf(pdf_file)).to include(expected_proof_of_service_values)
      end
    end
  end

  describe 'case details fields' do
    it 'fills out the case details' do
      expected_values = {
        'county' => 'CASC SAN FRANCISCO',
        'case_number' => '#ABCDE',
        'conviction_date' => '01/01/2010',
        'code_sections' => 'PC 484, PC 487d',
        'sentence' => '1y probation'
      }
      expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
    end

    context 'when the scenario is redesignation' do
      it 'fills out the reduction checkboxes' do
        expected_values = {
          'reduction_checkbox' => 'Yes',
          'reduction_checkbox_2' => 'Yes',
          'reduction_checkbox_3' => 'Yes',
          'resentencing_checkbox' => '',
          'resentencing_checkbox_2' => '',
          'resentencing_checkbox_3' => ''
        }
        expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
      end
    end

    context 'when the scenario is resentencing' do
      let(:remedy_details) { { scenario: :resentencing } }
      it 'fills out the resentencing checkboxes' do
        expected_values = {
          'reduction_checkbox' => '',
          'reduction_checkbox_2' => '',
          'reduction_checkbox_3' => '',
          'resentencing_checkbox' => 'Yes',
          'resentencing_checkbox_2' => 'Yes',
          'resentencing_checkbox_3' => 'Yes'
        }
        expect(get_fields_from_pdf(pdf_file)).to include(expected_values)
      end
    end
  end


end
