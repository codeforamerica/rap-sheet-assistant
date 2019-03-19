class PC1203Classifier
  include Classifier

  def initialize(event:, rap_sheet:)
    super(event: event, rap_sheet: rap_sheet)

    vc_sections = ""
    VC_DUI_CODE_SECTIONS.each do |cs|
      vc_sections = "#{vc_sections}|#{Regexp.escape(cs)}"
    end

    pc_sections = ""
    PC_DUI_CODE_SECTIONS.each do |cs|
      pc_sections = "#{pc_sections}|#{Regexp.escape(cs)}"
      end

    pc_sections_for_120342 = ""
    PC_DUI_CODE_SECTIONS.each do |cs|
      pc_sections_for_120342 = "#{pc_sections_for_120342}|#{Regexp.escape(cs)}"
      end

    hs_sections_for_120342 = ""
    PC_DUI_CODE_SECTIONS.each do |cs|
      hs_sections_for_120342 = "#{hs_sections_for_120342}|#{Regexp.escape(cs)}"
    end

    @vc_dui_matcher = /(VC)+.*(\W+((#{vc_sections[1..-1]})[\(\)\w]*)([\/\-\s]|$)+)+.*/
    @pc_dui_matcher = /(PC)+.*(\W+((#{pc_sections[1..-1]})[\(\)\w]*)([\/\-\s]|$)+)+.*/
    @pc_123042_matcher = /(PC)+.*(\W+((#{pc_sections_for_120342[1..-1]})[\(\)\w]*)([\/\-\s]|$)+)+.*/
    @hs_120342_matcher = /(PC)+.*(\W+((#{hs_sections_for_120342[1..-1]})[\(\)\w]*)([\/\-\s]|$)+)+.*/
  end

  def eligible?
    return false unless event.sentence
    return false unless event.date

    code = remedy_details_hash[:code]
    if code == '1203.4'
      return true if event.date < Date.today - event.sentence.total_duration
    elsif code == '1203.4a'
      return true if event.date < Date.today - 1.year
    elsif code == '1203.41'
      return true if !event.sentence.prison && event.date < Date.today - event.sentence.total_duration - 2.year
    elsif code == '1203.42'
      return true if event.date < Date.today - event.sentence.total_duration - 2.year
    end
    false
  end

  def remedy_details
    if eligible?
      remedy_details_hash
    else
      nil
    end
  end

  def dui?(count)
    if !count.code_section
      return false
    end
    count.code_section.match(@vc_dui_matcher) || count.code_section.match(@pc_dui_matcher)
  end

  def count_for_42
    if !count.code_section
      return false
    end
    count.code_section.match(@pc_123042_matcher) || count.code_section.match(@hs_120342_matcher)
  end

  def discretionary?
    r = remedy_details_hash
    return nil if r.empty?
    r[:code] == '1203.41' || r[:scenario] == :discretionary
  end

  def eligible_counts
    if eligible?
      event.convicted_counts
    else
      []
    end
  end

  private

  def scenario_for_code(code)
    if code == '1203.4'
      success = !event.probation_violated?(rap_sheet)
    elsif code == '1203.4a'
      success = event.successfully_completed_duration?(rap_sheet, 1.year)
    else
      return nil
    end
    return :discretionary if event.counts.any? { |count| dui?(count) }
    return :unknown if event.date.nil? || success.nil?
    success ? :successful_completion : :discretionary
  end

  def remedy_details_hash
    return {} unless event.sentence

    if event.sentence.probation
      code = '1203.4'
    else
      code =
        case event.severity
        when 'M'
          '1203.4a'
        when 'I'
          '1203.4a'
        when 'F'
          if event.date < Date.new(2011, 7, 1)
            && count_for_42
            '1203.42'
          else
            '1203.41'
          end
        else
          nil
        end
    end

    return {} if code.nil?

    {
      code: code,
      scenario: scenario_for_code(code)
    }
  end
end

PC_DUI_CODE_SECTIONS = [
  '191.5',
  '192(c)'
]

VC_DUI_CODE_SECTIONS = [
  '12810(a)',
  '12810(b)',
  '12810(c)',
  '12810(d)',
  '12810(e)',
  '14601',
  '14601.1',
  '14601.2',
  '14601.3',
  '14601.5',
  '20001',
  '20002',
  '21651(b)',
  '22348(b)',
  '23109(a)',
  '23109(c)',
  '23140(a)',
  '23140(b)',
  '23152',
  '23153',
  '2800',
  '2800.2',
  '2800.3',
  '2801',
  '2803',
  '31602',
  '42002.1'
]
# 1203.42 code sections
# HS	1390
# HS	1522.01(c)
# HS	1621.5(a)
# HS	7051
# HS	7051.5
# HS	8113.5(a)
# HS	8113.5(a)
# HS	8785
# HS	11100(f)(1)
# HS	11100.1(a)
# HS	11105(a)
# HS	11105(a)
# HS	11153(a)
# HS	11153.5(a)
# HS	11162.5(a)
# HS	11350(a)
# HS	11350(b)
# HS	11351
# HS	11351.5
# HS	11352(a)
# HS 	11352(b)
# HS	11353.5
# HS	11353.6(b)
# HS	11353.6(c)
# HS	11353.7
# HS	11355
# HS	11357(a)
# HS	11358
# HS	11359
# HS	11360(a)
# HS	11366.5(a)
# HS	11366.5(a)
# HS	11366.5(b)
# HS	11366.6
# HS	11366.8(a)
# HS	11366.8(b)
# HS	11370.6(a)
# HS	11371
# HS	11371.1
# HS	11374.5
# HS	11377(a)
# HS	11378
# HS	11378.5
# HS	11379(a)
# HS	11379(b)
# HS	11379.5(a)
# HS	11379.5(b)
# HS	11379.6(a)
# HS	11379.6(c)
# HS	11380.7(a)
# HS	11383(b)
# HS	11383(c)
# HS	11383(d)
# HS	11383.5(a)
# HS	11383.5(b)(1)
# HS	11383.5(b)(2)
# HS	11383.5(c)
# HS	11383.5(d)
# HS	11383.5(e)
# HS	11383.5(f)
# HS	11383.6(a)
# HS	11383.6(b)
# HS	11383.6(c)
# HS	11383.6(d)
# HS	11383.7(a)
# HS	11383.7(b)(1)
# HS	11383.7(b)(2)
# HS	11383.7(c)
# HS	11383.7(d)
# HS	11383.7(e)
# HS	11383.7(f)
# HS	12401
# HS	12700(b)(3)
# HS	12700(b)(4)
# HS	17601(b)
# HS	18124.5
# HS	25162(c)
# HS	25162(d)
# HS	25162(e)
# HS	25180.7(b)
# HS	25189.5(b)
# HS	25189.5(b)
# HS	25189.5(c)
# HS	25189.5(c)
# HS	25189.5(d)
# HS	25189.5(d)
# HS	25189.6(a)
# HS	25189.6(b)
# HS	25189.7(b)
# HS	25189.7(b)
# HS	25190
# HS	25191(b)(1)
# HS	25191(b)(2)
# HS	25191(b)(3)
# HS	25191(b)(4)
# HS	25191(b)(5)
# HS	25191(b)(6)
# HS	25191(b)(7)
# HS	25395.13(b)
# HS	25507(a)
# HS	25541
# HS	42400.3(c)
# HS	44209
# HS	100895(a)(1)
# HS	100895(a)(2)
# HS	100895(a)(3)
# HS	100895(a)(4)
# HS	109335
# HS	115215(b)(1)
# HS	115215(b)(2)
# HS	115215(c)(1)
# HS	115215(c)(2)
# HS	116730(a)(1)
# HS	116730(a)(2)
# HS	116730(a)(3)
# HS	116730(a)(4)
# HS	116750(a)
# HS	116750(b)
# HS	118340(a)
# HS	118340(d)
# HS	131130
#
#
# PC	33
# PC	38
# PC	67.5(b)
# PC	69
# PC	71(a)
# PC	72
# PC	72.5(b)
# PC	76(a)
# PC	95
# PC	95.1
# PC	96
# PC	99
# PC	107
# PC	109
# PC	113
# PC	114
# PC	115.1(b)
# PC	118
# PC	119
# PC	120
# PC	121
# PC	122
# PC	123
# PC	124
# PC	125
# PC	126
# PC	136.7
# PC	137(b)
# PC	139(a)
# PC	140(a)
# PC	142(a)
# PC	146a(b)
# PC	146e(a)
# PC	148(b)
# PC	148(c)
# PC	148(d)
# PC	148.1(a)
# PC	148.1(b)
# PC	148.1(c)
# PC	148.1(d)
# PC	148.3(b)
# PC	148.4(b)
# PC	148.10
# PC	149
# PC	153(1)
# PC	153(2)
# PC	156
# PC	157
# PC	168(a)
# PC	171c(a)(1)
# PC	171d(a)
# PC	171d(b)
# PC	181
# PC	182
# PC	182(a)(2)
# PC	182(a)(3)
# PC	182(a)(4)
# PC	182(a)(5)
# PC	182(a)(6)
# PC	186.10(a)
# PC	186.10(c)(1)(A)
# PC	186.10(c)(1)(B)
# PC	186.10(c)(1)(C)
# PC	186.10(c)(1)(D)
# PC	186.28
# PC	191.5(b)
# PC	192(b)
# PC  193(b)
# PC	192.5(b)
# PC  193.5(b
# PC	210.5
# PC	217.1(a)
# PC	218.1
# PC	219.1
# PC	222
# PC	236-237(a)
# PC	240-241.1
# PC	240-241.4
# PC	240-241.7
# PC	242-243(c)(1)
# PC	242-243(c)(2)
# PC	242-243(d)
# PC	242-243.1
# PC	242-243.6
# PC	244.5(b)
# PC	244.5(c)
# PC	245.6(d)
# PC	246.3(a)
# PC	247.5
# PC	261.5(c)
# PC	261.5(d)
# PC	265
# PC	266b
# PC	266e
# PC	266f
# PC	266g
# PC	271
# PC	271a
# PC	273.6(a)
# PC	273.6(a)
# PC	273.65(a)
# PC	273.65(a)
# PC	273d(a)
# PC	278
# PC	278.5
# PC	280(b)
# PC	284
# PC	288.2(a)
# PC	288.2(a)
# PC	288.2(b)
# PC	288.2(b)
# PC	290.4
# PC	290.45
# PC	290.46
# PC 	311.2(a)
# PC	311.5
# PC	311.4(a)
# PC	311.7
# PC	313.1
# PC	337.3
# PC	337.7
# PC	337b
# PC	337c
# PC	337d
# PC	337e
# PC	337f
# PC	350(a)(1)
# PC	350(a)(2)
# PC	350(a)
# PC 	367f(a)
# PC 	367f(b)
# PC	367g(a)
# PC	367g(b)
# PC	368(d)
# PC	368(e)
# PC	368(f)
# PC	374.2(a)
# PC	374.8(b)
# PC	375(a)
# PC	382.5
# PC	382.6
# PC	386(a)
# PC	386(a)
# PC	387(a)
# PC	399.5(a)
# PC	404.6(a)
# PC	405b
# PC	417.3
# PC	417.6
# PC	422.7
# PC	453(a)
# PC	459-460(b)
# PC	463
# PC	464
# PC	470(a)
# PC	470(b)
# PC	470(c)
# PC	470(d)
# PC	470a
# PC	470b
# PC	471
# PC	472
# PC	475(a)
# PC	475(b)
# PC	475(c)
# PC	476
# PC	478-477
# PC	478-479
# PC	478-480(a)
# PC	478-481
# PC	483.5(a)
# PC	484b
# PC	484e(a)
# PC	484e(b)
# PC	484e(d)
# PC	484f(a)
# PC	484f(b)
# PC	484g
# PC	484h(a)
#  	484h(b)
# PC	484i(b)
# PC	484i(c)
# PC	487(a)
# PC	487(b)(1)(A)
# PC	487(b)(2)
# PC	487(b)(3)
# PC	487(c)
# PC	487(d)(1)
# PC	487a(a)
# PC	487a(b)
# PC	487b
# PC	487d
# PC	487e
# PC	487h(a)
# PC	487i
# PC	496(a)
# PC	496(b)
# PC	496(d)
# PC	496a(a)
# PC	496d(a)
# PC	499c(c)
# PC	499d
# PC	500(a)
# PC	502(c)(1)
# PC	502(c)(2)
# PC	502(c)(3)
# PC	502(c)(4)
# PC	502(c)(5)
# PC	502(c)(6)
# PC	502(c)(7)
# PC	502(c)(8)
# PC	504
# PC	504a
# PC	504b
# PC	505
# PC	506
# PC	508
# PC	520
# PC	522
# PC	523
# PC	524
# PC	529(a)
# PC	529a(a)
# PC	530.5(a)
# PC	530.5(c)(2)
# PC	530.5(c)(3)
# PC	530.5(d)(1)
# PC	530.5(d)(2)
# PC	532a(1)
# PC	532a(2)
# PC	532a(3)
# PC	532f(a)
# PC	533
# PC	535
# PC	537e(a)
# PC	538.5
# PC	548(a)
# PC	549
# PC	549
# PC	550(a)(1)
# PC	550(a)(2)
# PC 	550(a)(3)
# PC	550(a)(4)
# PC 	550(a)(5)
# PC	550(a)(6)
# PC	550(a)(7)
# PC 	550(a)(8)
# PC	550(a)(9)
# PC	550(b)(1)
# PC	550(b)(2)
# PC	550(b)(3)
# PC	550(b)(4)
# PC	551(a)
# PC	551(b)
# PC	560
# PC	560.4
# PC	566
# PC	570
# PC  571
# PC	577
# PC	578
# PC	580
# PC	581
# PC	587(a)
# PC	587(b)
# PC	587.1(b)
# PC	591
# PC	593
# PC	594(a)(1)
# PC	594(a)(2)
# PC	594(a)(3)
# PC	594.3(a)
# PC	594.3(b)
# PC	594.35(a)
# PC	594.35(b)
# PC	594.35(c)
# PC	594.35(d)
# PC	594.4(a)
# PC	597(a)
# PC	597(b)
# PC	597(c)
# PC	597.5(a)(1)
# PC	597.5(a)(2)
# PC	597.5(a)(3)
# PC	601(a)(1)
# PC	601(a)(2)
# PC	610
# PC	617
# PC	620
# PC	621
# PC	625b(b)
# PC	626.9(b)
# PC	626.9(h)
# PC	626.9(i)
# PC	626.95(a)
# PC	626.10(a)(1)
# PC	626.10(b)
# PC	629.84
# PC	631(a)
# PC	636(a)
# PC	636(b)
# PC	637
# PC	647.6(b)
# PC	647.6
# PC	647.6
# PC	653f(a)
# PC	653f(c)
# PC	653f(d)(1)
# PC	653f(e)
# PC	653h(a)
# PC	653h(a)(1)
# PC	653h(a)(2)
# PC	653h(d)(1)
# PC	653h(d)(2)
# PC	653j(a)
# PC	653s(a)
# PC	653s(a)
# PC	653s(i)
# PC	653s(i)
# PC	653t(a)
# PC	653t(d)
# PC	653u(a)
# PC	653u(a)
# PC	653w(a)(1)
# PC	653w(a)(1)
# PC	664(a)
# PC	666(a)
# PC	666.5(a)
# PC	667.5(b)
# PC	836.6(a)
# PC	836.6(b)
# PC	1320(b)
# PC	1320.5
# PC	2772
# PC	4011.7
# PC	4131.5
# PC	4502(a)
# PC	4502(b)
# PC	4533
# PC	4536(a)
# PC	4550(a)
# PC	4550(b)
# PC	4573(a)
# PC	4573.6(a)
# PC	4573.9(a)
# PC	4574(a)
# PC	4574(b)
# PC	4600(a)
# PC	11411(c)
# PC	11411(d)
# PC	11413(a)
# PC	11418(a)(1)
# PC	11418(a)(2)
# PC	11419(a)
# PC	12022(a)(1)
# PC	12022(a)(2)
# PC	12022(c)
# PC	12022(d)
# PC	12035(b)(1)
# PC	12040(a)
# PC	12072(a)(1)
# PC	12072(a)(2)
# PC	12072(a)(3)
# PC	12072(a)(4)
# PC	12072(a)(5)
# PC	12072(b)
# PC	12072(b)
# PC	12072(c)(1)
# PC	12072(c)(3)
# PC	12072(c)(4)
# PC	12072(c)(5)
# PC	12072(c)(6)
# PC	12072(d)
# PC	12072(e)
# PC	12072(g)(4)
# PC	12072(g)(2)
# PC	12076(b)(1)
# PC	12076(c)(1)
# PC	12090
# PC	12101(a)(1)
# PC	12101
# PC	12220(a)
# PC	12220(b)
# PC	12280(a)(1)
# PC	12280(a)(2)
# PC	12280(b)
# PC	12303.3
# PC	12303.6
# PC	12304
# PC	12312
# PC	12320
# PC	12355(a)
# PC	12355(b)
# PC	12370
# PC	12403.7(g)
# PC	12422
# PC	12520
# PC	18715(a)
# PC	18720
# PC	18725
# PC	18730
# PC	18735(a)
# PC	18740
# PC	20110(a)
# PC	20110(b)
# PC	22810(g)(1)
# PC	22810(g)(2)
# PC	22910
# PC	23900
# PC	25110
# PC	25300(a)
# PC	25400(a)
# PC	25400(a)
# PC	25850
# PC	27500(a)
# PC	27500(b)
# PC	27500(b)
# PC	27510
# PC	27510
# PC	27510
# PC	27515
# PC	27520
# PC	27540(a)
# PC	27540(c)
# PC	27540(d)
# PC	27540(e)
# PC	27540(f)
# PC	27545
# PC	27550
# PC	27590(b)
# PC	27590(b)
# PC	28250(b)
# PC	29700
# PC	30315
# PC	30600(a)
# PC	30600(b)
# PC	30605
# PC	30720
# PC	31360
# PC	32625(a)
# PC	32625(b)
# PC	33410
