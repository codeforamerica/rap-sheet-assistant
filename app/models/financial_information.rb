class FinancialInformation < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  validates :user_id, uniqueness: true

  BENEFITS_TYPES = {
    food_stamps: 'Food Stamps',
    supp_sec_inc: 'Supp. Sec. Inc.',
    ssp: 'SSP',
    medi_cal: 'Medi-Cal',
    county_relief: 'County Relief/Gen. Assist.',
    ihss: 'IHSS',
    cal_works: 'CalWORKS or Tribal TANF',
    capi: 'CAPI',
  }

  BASE_MONTHLY_INCOME_LIMIT = 814.59
  HOUSEHOLD_SIZE_INCOME_MODIFIER = 450
end
