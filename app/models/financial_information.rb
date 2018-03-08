class FinancialInformation < ApplicationRecord
  belongs_to :user

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
end
