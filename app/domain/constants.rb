module Constants
# https://wiperecord.com/california-felony-reductions-and-wobbler-criminal-offenses
# code mappings are from https://oag.ca.gov/sites/all/files/agweb/pdfs/cjsc/prof10/codes.pdf
# Exact matches only
  WOBBLERS = [
    "PC 32",
    "PC 69",
    "PC 71",
    "PC 72",
    "PC 95",
    "PC 95.1",
    "PC 96",
    "PC 99",
    "PC 100",
    "PC 107",
    "PC 115.1",
    "PC 118.1",
    "PC 136.1(a)",
    "PC 136.1(b)",
    "PC 136.5",
    "PC 148.10",
    "PC 149",
    "PC 166(c)(4)",
    "PC 166(d)",
    "PC 168",
    "PC 171b",
    "PC 171c",
    "PC 171d",
    "PC 182(a)(1)",
    "PC 182(a)(2)",
    "PC 182(a)(3)",
    "PC 182(a)(4)",
    "PC 182(a)(5)",
    "PC 182.5",
    "PC 186.22(a)",
    "PC 186.22(a)",
    "PC 186.22(b)(1)",
    "PC 186.22(c)",
    "PC 186.22(d)",
    "PC 186.26(a)",
    "PC 186.26(b)",
    "PC 186.28",
    "PC 192(c)(1)",
    "PC 192(c)(3)",
    "PC 192.5(a)",
    "PC 192.5(c)(3)",
    "PC 227",
    "PC 231",
    "PC 227",
    "PC 231/227",
    "PC 241.1",
    "PC 241.4",
    "PC 241.7",
    "PC 243(c)",
    "PC 243(c)(1)",
    "PC 243(c)(2)",
    "PC 243(d)",
    "PC 243.3",
    "PC 243.4(a)(d)",
    "PC 243.6",
    "PC 243.7",
    "PC 243.9(a)",
    "PC 244.5(b)",
    "PC 244.5(c)",
    "PC 245(a)(1)",
    "PC 245(a)(2)",
    "PC 245.5(b)",
    "PC 245.5(c)",
    "PC 246",
    "PC 247(b)",
    "PC 247.5",
    "PC 261.5",
    "PC 261.5(c)",
    "PC 261.5(d)",
    "PC 262",
    "PC 266",
    "PC 266c",
    "PC 267",
    "PC 270",
    "PC 271",
    "PC 271a",
    "PC 273(c)",
    "PC 273a(1)",
    "PC 273a(a)(1)",
    "PC 273a(a)",
    "PC 273d",
    "PC 273d(a)",
    "PC 273.5",
    "PC 273.5(a)",
    "PC 273.5(e)",
    "PC 273.5(e)(1)",
    "PC 273.5(e)(2)",
    "PC 273.6(c)",
    "PC 273.6(d)",
    "PC 273.6(d)",
    "PC 273.6(e)",
    "PC 273.55",
    "PC 273.65(d)",
    "PC 273.65(e)",
    "PC 276",
    "PC 278",
    "PC 278.5",
    "PC 280(b)",
    "PC 283",
    "PC 284",
    "PC 286(b)(1)",
    "PC 286(e)",
    "PC 286(h)",
    "PC 288(c)",
    "PC 288(c)(1)",
    "PC 288(c)(2)",
    "PC 288.2",
    "PC 288.2(a)",
    "PC 288.2(b)",
    "PC 288a(b)(1)",
    "PC 288a(e)",
    "PC 288a(h)",
    "PC 289(c)",
    "PC 289(c)",
    "PC 289(h)",
    "PC 289(h)",
    "PC 289.6(a)(2)",
    "PC 289.6(a)(3)",
    "PC 290(g)(2)",
    "PC 290(g)(2)",
    "PC 290(g)(3)",
    "PC 290(g)(5)",
    "PC 290(g)(5)",
    "PC 299.5(g)",
    "PC 311.1",
    "PC 311.2(d)",
    "PC 311.2(d)",
    "PC 311.10",
    "PC 314(1)",
    "PC 332",
    "PC 334(a)",
    "PC 337a",
    "PC 337b",
    "PC 337c",
    "PC 337d",
    "PC 337e",
    "PC 337f(c)",
    "PC 337f(d)",
    "PC 337i",
    "PC 337.3",
    "PC 337.7",
    "PC 347(b)",
    "PC 350(a)(2)",
    "PC 350(a)(2)",
    "PC 350(b)",
    "PC 350(b)",
    "PC 350(d)(1)",
    "PC 350(d)(2)",
    "PC 350(d)(30)",
    "PC 367f",
    "PC 368(a)",
    "PC 368(b)",
    "PC 368(c)",
    "PC 368(d)",
    "PC 368(e)",
    "PC 374.2",
    "PC 374.8",
    "PC 382.5",
    "PC 382.6",
    "PC 387",
    "PC 399(b)",
    "PC 399.5",
    "PC 404.6(c)",
    "PC 417(b)",
    "PC 417(b)",
    "PC 417(c)",
    "PC 417.1",
    "PC 417.6",
    "PC 422",
    "PC 422.7",
    "PC 452(a)",
    "PC 452(b)",
    "PC 452(c)",
    "PC 453(a)",
    "PC 453(a)",
    "PC 453(b)",
    "PC 461(2)",
    "PC 463(a)",
    "PC 463(a)",
    "PC 463(b)",
    "PC 463(b)",
    "PC 463(b)",
    "PC 470",
    "PC 470a",
    "PC 470b",
    "PC 471",
    "PC 472",
    "PC 474",
    "PC 475",
    "PC 475a",
    "PC 476",
    "PC 476a",
    "PC 483.5(d)",
    "PC 484b",
    "PC 484e(a)",
    "PC 484e(b)",
    "PC 484e(d)",
    "PC 484g",
    "PC 484g",
    "PC 484h",
    "PC 484i(b)",
    "PC 484i(b)",
    "PC 484i(c)",
    "PC 487(1)",
    "PC 487(2)",
    "PC 487(3)",
    "PC 487(3)",
    "PC 487(a)",
    "PC 487(b)(1)",
    "PC 487(b)(2)",
    "PC 487(b)(3)",
    "PC 487(c)",
    "PC 487(d)",
    "PC 487(d)",
    "PC 487a",
    "PC 487e",
    "PC 487g",
    "PC 487g",
    "PC 487h(a)",
    "PC 487h(a)",
    "PC 496(1)",
    "PC 496(a)",
    "PC 496(b)",
    "PC 496(e)",
    "PC 496(d)",
    "PC 496a",
    "PC 496c",
    "PC 496d",
    "PC 497",
    "PC 499(a)",
    "PC 499(b)",
    "PC 499b.1(a)",
    "PC 499b.1(b)",
    "PC 499c",
    "PC 499d",
    "PC 502(d)",
    "PC 502(d)",
    "PC 502.5",
    "PC 502.7(a)",
    "PC 502.7(a)",
    "PC 502.7(b)",
    "PC 502.7(b)",
    "PC 502.7(d)",
    "PC 502.7(g)",
    "PC 502.8(c)",
    "PC 502.8(d)",
    "PC 503",
    "PC 504",
    "PC 504a",
    "PC 504b",
    "PC 505",
    "PC 506",
    "PC 506b",
    "PC 507",
    "PC 508",
    "PC 524",
    "PC 529",
    "PC 530",
    "PC 530.5",
    "PC 532",
    "PC 532a(4)",
    "PC 535",
    "PC 537(a)(2)",
    "PC 537e(a)",
    "PC 538",
    "PC 538.5",
    "PC 540",
    "PC 541",
    "PC 542",
    "PC 549",
    "PC 550(a)(6)",
    "PC 550(b)(1)",
    "PC 550(b)(2)",
    "PC 551",
    "PC 560",
    "PC 560.4",
    "PC 566",
    "PC 570",
    "PC 577",
    "PC 578",
    "PC 580",
    "PC 581",
    "PC 587",
    "PC 591",
    "PC 592(b)",
    "PC 593",
    "PC 593d(b)",
    "PC 594(b)(1)",
    "PC 594(b)(1)",
    "PC 594(b)(2)",
    "PC 594.3(a)",
    "PC 594.3(a)",
    "PC 594.35",
    "PC 594.4",
    "PC 594.7",
    "PC 597",
    "PC 600(a)",
    "PC 601",
    "PC 601",
    "PC 607",
    "PC 620",
    "PC 621",
    "PC 625b(b)",
    "PC 626.9(b)",
    "PC 626.10(a)",
    "PC 626.10(a)",
    "PC 626.10(b)",
    "PC 626.10(b)",
    "PC 626.95",
    "PC 629.84",
    "PC 631",
    "PC 632",
    "PC 632.5",
    "PC 632.6",
    "PC 632.7",
    "PC 634",
    "PC 635",
    "PC 636(b)",
    "PC 637",
    "PC 637.1",
    "PC 641.3",
    "PC 642",
    "PC 646.9(a)",
    "PC 646.9(b)",
    "PC 646.9(c)",
    "PC 646.9(c)(1)",
    "PC 647.6",
    "PC 653f(a)",
    "PC 653f(d)",
    "PC 653f(e)",
    "PC 653h(b)",
    "PC 653h(c)",
    "PC 653h(d)",
    "PC 666",
    "PC 666",
    "PC 1319.4",
    "PC 1320(b)",
    "PC 1320.5",
    "PC 1370.5",
    "PC 4011.7",
    "PC 4131.5",
    "PC 4133",
    "PC 4501.1",
    "PC 4532(a)",
    "PC 4532(b)",
    "PC 4532(b)",
    "PC 4532(d)",
    "PC 4532(d)",
    "PC 4536",
    "PC 4550(2)",
    "PC 11411(b)",
    "PC 14411(c)",
    "PC 11411(c)",
    "PC 11418(d)",
    "PC 11418.1",
    "PC 11418.5",
    "PC 12020",
    "PC 12020",
    "PC 12021(c)",
    "PC 12021(d)",
    "PC 12021(e)",
    "PC 12021(g)",
    "PC 12021.3",
    "PC 12023",
    "PC 12025(a)",
    "PC 12025(a)",
    "PC 12025(b)",
    "PC 12031(a)",
    "PC 12031(a)",
    "PC 12031.5(a)",
    "PC 12034(b)",
    "PC 12034(d)",
    "PC 12035(b)(1)",
    "PC 12040",
    "PC 12072",
    "PC 12072",
    "PC 12072(a)",
    "PC 12100",
    "PC 12100",
    "PC 12101",
    "PC 12220",
    "PC 12220(a)",
    "PC 12220(b)",
    "PC 12303",
    "PC 12304",
    "PC 12316(b)",
    "PC 12320",
    "PC 12321",
    "PC 12355(b)",
    "PC 12403.7",
    "PC 12422",
    "PC 12520",
    "PC 14166",
    "BP 580",
    "BP 581",
    "BP 582",
    "BP 583",
    "BP 584",
    "BP 650",
    "BP 729",
    "BP 729",
    "BP 729",
    "BP 729",
    "BP 729",
    "BP 1282.3",
    "BP 2052(a)",
    "BP 2052(b)",
    "BP 2053",
    "BP 4324",
    "BP 6126(b)",
    "BP 6126(c)",
    "BP 6152",
    "BP 7026.10",
    "BP 7027.3",
    "BP 7028.16",
    "BP 10238.6",
    "BP 10250.56",
    "BP 11010.1",
    "BP 11013.1",
    "BP 11013.2",
    "BP 11013.4",
    "BP 11018.2",
    "BP 11019",
    "BP 11022",
    "BP 17511.9",
    "BP 22430(d)",
    "CI 892",
    "CI 1695.8",
    "CI 1812.116(b)",
    "CI 1812.217",
    "CI 2945.4",
    "CI 2985.2",
    "CI 2985.3",
    "CC 2255",
    "CC 2256",
    "CC 6811",
    "CC 6812",
    "CC 6813",
    "CC 6814",
    "CC 8812",
    "CC 8813",
    "CC 8814",
    "CC 8815",
    "CC 12672",
    "CC 12673",
    "CC 12674",
    "CC 12675",
    "CC 22002",
    "CC 25110",
    "CC 25120",
    "CC 25130",
    "CC 25164",
    "CC 25166",
    "CC 25210",
    "CC 25214(a)",
    "CC 25216",
    "CC 25218",
    "CC 25230",
    "CC 25232.2",
    "CC 25234(a)",
    "CC 25235",
    "CC 25243",
    "CC 25245",
    "CC 25246",
    "CC 25300(a)",
    "CC 25400",
    "CC 25401",
    "CC 25402",
    "CC 25403",
    "CC 25404"
  ]

  #exact matches only
  REDUCIBLE_TO_INFRACTION = [
    "PC 193.8",
    "PC 330",
    "PC 415",
    "PC 485",
    "PC 490.7",
    "PC 555",
    "PC 602.13",
    "PC 853.7",
    "PC 532b(c)",
    "PC 602(o)",
    "BP 25658(b)",
    "BP 21672",
    "BP 25661",
    "BP 25662",
    "GC 27204",
    "VC 23109(c)",
    "VC 5201.1",
    "VC 12500",
    "VC 14601.1",
    "VC 27150.1",
    "VC 40508",
    "VC 42005"
  ]

  # Match including subsections
  CODE_SECTIONS_EXCLUDED_FOR_PC1203_DISMISSALS = [
    'PC 286(c)',
    'PC 288',
    'PC 288a(c)',
    'PC 311.1',
    'PC 311.2',
    'PC 311.3',
    'PC 311.11',
    'VC 2800',
    'VC 2801',
    'VC 2803'
  ]

  # Match including subsections
  PC_1203_DISCRETIONARY_CODE_SECTIONS = [
    'PC 191.5',
    'PC 191.5(b)',
    'PC 192(c)',
    'VC 12810(a)',
    'VC 12810(b)',
    'VC 12810(c)',
    'VC 12810(d)',
    'VC 12810(e)',
    'VC 14601',
    'VC 14601.1',
    'VC 14601.2',
    'VC 14601.3',
    'VC 14601.5',
    'VC 20001',
    'VC 20002',
    'VC 21651(b)',
    'VC 22348(b)',
    'VC 23109(a)',
    'VC 23109(c)',
    'VC 23109.1',
    'VC 23140(a)',
    'VC 23140(b)',
    'VC 23152',
    'VC 23153',
    'VC 2800',
    'VC 2800.2',
    'VC 2800.3',
    'VC 2801',
    'VC 2803',
    'VC 31602',
    'VC 42002.1'
  ]

  # AB 109 is also known as "realignment", or "1170(h)"
  # These felonies are now sentenced to county jail instead of state prison
  # Exact matches only
  PC_1170H_FELONIES = [
    'HS 1390',
    'HS 1522.01(c)',
    'HS 1621.5(a)',
    'HS 7051',
    'HS 7051.5',
    'HS 8113.5(a)',
    'HS 8113.5(a)',
    'HS	8785',
    'HS 11100(f)(1)',
    'HS 11100.1(a)',
    'HS 11105(a)',
    'HS 11105(a)',
    'HS 11153(a)',
    'HS 11153.5(a)',
    'HS 11162.5(a)',
    'HS 11350(a)',
    'HS 11350(b)',
    'HS 11351',
    'HS 11351.5',
    'HS 11352(a)',
    'HS 11352(b)',
    'HS 11353.5',
    'HS 11353.6(b)',
    'HS 11353.6(c)',
    'HS 11353.7',
    'HS 11355',
    'HS 11357(a)',
    'HS 11358',
    'HS 11359',
    'HS 11360(a)',
    'HS 11366.5(a)',
    'HS 11366.5(a)',
    'HS 11366.5(b)',
    'HS 11366.6',
    'HS 11366.8(a)',
    'HS 11366.8(b)',
    'HS 11370.6(a)',
    'HS 11371',
    'HS 11371.1',
    'HS 11374.5',
    'HS 11377(a)',
    'HS 11378',
    'HS 11378.5',
    'HS 11379(a)',
    'HS 11379(b)',
    'HS 11379.5(a)',
    'HS 11379.5(b)',
    'HS 11379.6(a)',
    'HS 11379.6(c)',
    'HS 11380.7(a)',
    'HS 11383(b)',
    'HS 11383(c)',
    'HS 11383(d)',
    'HS 11383.5(a)',
    'HS 11383.5(b)(1)',
    'HS 11383.5(b)(2)',
    'HS 11383.5(c)',
    'HS 11383.5(d)',
    'HS 11383.5(e)',
    'HS 11383.5(f)',
    'HS 11383.6(a)',
    'HS 11383.6(b)',
    'HS 11383.6(c)',
    'HS 11383.6(d)',
    'HS 11383.7(a)',
    'HS 11383.7(b)(1)',
    'HS 11383.7(b)(2)',
    'HS 11383.7(c)',
    'HS 11383.7(d)',
    'HS 11383.7(e)',
    'HS 11383.7(f)',
    'HS 12401',
    'HS 12700(b)(3)',
    'HS 12700(b)(4)',
    'HS 17601(b)',
    'HS 18124.5',
    'HS 25162(c)',
    'HS 25162(d)',
    'HS 25162(e)',
    'HS 25180.7(b)',
    'HS 25189.5(b)',
    'HS 25189.5(b)',
    'HS 25189.5(c)',
    'HS 25189.5(c)',
    'HS 25189.5(d)',
    'HS 25189.5(d)',
    'HS 25189.6(a)',
    'HS 25189.6(b)',
    'HS 25189.7(b)',
    'HS 25189.7(b)',
    'HS 25190',
    'HS 25191(b)(1)',
    'HS 25191(b)(2)',
    'HS 25191(b)(3)',
    'HS 25191(b)(4)',
    'HS 25191(b)(5)',
    'HS 25191(b)(6)',
    'HS 25191(b)(7)',
    'HS 25395.13(b)',
    'HS 25507(a)',
    'HS 25541',
    'HS 42400.3(c)',
    'HS 44209',
    'HS 100895(a)(1)',
    'HS 100895(a)(2)',
    'HS 100895(a)(3)',
    'HS 100895(a)(4)',
    'HS 109335',
    'HS 115215(b)(1)',
    'HS 115215(b)(2)',
    'HS 115215(c)(1)',
    'HS 115215(c)(2)',
    'HS 116730(a)(1)',
    'HS 116730(a)(2)',
    'HS 116730(a)(3)',
    'HS 116730(a)(4)',
    'HS 116750(a)',
    'HS 116750(b)',
    'HS 118340(a)',
    'HS 118340(d)',
    'HS 131130',
    'PC 33',
    'PC 38',
    'PC 67.5(b)',
    'PC 69',
    'PC 71(a)',
    'PC 72',
    'PC 72.5(b)',
    'PC 76(a)',
    'PC 95',
    'PC 95.1',
    'PC 96',
    'PC 99',
    'PC 107',
    'PC 109',
    'PC 113',
    'PC 114',
    'PC 115.1(b)',
    'PC 118',
    'PC 119',
    'PC 120',
    'PC 121',
    'PC 122',
    'PC 123',
    'PC 124',
    'PC 125',
    'PC 126',
    'PC 136.7',
    'PC 137(b)',
    'PC 139(a)',
    'PC 140(a)',
    'PC 142(a)',
    'PC 146a(b)',
    'PC 146e(a)',
    'PC 148(b)',
    'PC 148(c)',
    'PC 148(d)',
    'PC 148.1(a)',
    'PC 148.1(b)',
    'PC 148.1(c)',
    'PC 148.1(d)',
    'PC 148.3(b)',
    'PC 148.4(b)',
    'PC 148.10',
    'PC 149',
    'PC 153(1)',
    'PC 153(2)',
    'PC 156',
    'PC 157',
    'PC 168(a)',
    'PC 171c(a)(1)',
    'PC 171d(a)',
    'PC 171d(b)',
    'PC 181',
    'PC 182',
    'PC 182(a)(2)',
    'PC 182(a)(3)',
    'PC 182(a)(4)',
    'PC 182(a)(5)',
    'PC 182(a)(6)',
    'PC 186.10(a)',
    'PC 186.10(c)(1)(A)',
    'PC 186.10(c)(1)(B)',
    'PC 186.10(c)(1)(C)',
    'PC 186.10(c)(1)(D)',
    'PC 186.28',
    'PC 191.5(b)',
    'PC 192(b)',
    'PC 193(b)',
    'PC 192.5(b)',
    'PC 193.5(b)',
    'PC 210.5',
    'PC 217.1(a)',
    'PC 218.1',
    'PC 219.1',
    'PC 222',
    'PC 236-237(a)', ##Research all exact code sections
    'PC 240-241.1', ##Research all exact code sections
    'PC 240-241.4', ##Research all exact code sections
    'PC 240-241.7', ##Research all exact code sections
    'PC 242-243(c)(1)', ##Research all exact code sections
    'PC 242-243(c)(2)', ##Research all exact code sections
    'PC 242-243(d)', ##Research all exact code sections
    'PC 242-243.1', ##Research all exact code sections
    'PC 242-243.6', ##Research all exact code sections
    'PC 244.5(b)',
    'PC 244.5(c)',
    'PC 245.6(d)',
    'PC 246.3(a)',
    'PC 247.5',
    'PC 261.5(c)',
    'PC 261.5(d)',
    'PC 265',
    'PC 266b',
    'PC 266e',
    'PC 266f',
    'PC 266g',
    'PC 271',
    'PC 271a',
    'PC 273.6(a)',
    'PC 273.6(a)',
    'PC 273.65(a)',
    'PC 273.65(a)',
    'PC 273d(a)',
    'PC 278',
    'PC 278.5',
    'PC 280(b)',
    'PC 284',
    'PC 288.2(a)',
    'PC 288.2(a)',
    'PC 288.2(b)',
    'PC 288.2(b)',
    'PC 290.4',
    'PC 290.45',
    'PC 290.46',
    'PC 311.2(a)',
    'PC 311.5',
    'PC 311.4(a)',
    'PC 311.7',
    'PC 313.1',
    'PC 337.3',
    'PC 337.7',
    'PC 337b',
    'PC 337c',
    'PC 337d',
    'PC 337e',
    'PC 337f',
    'PC 350(a)(1)',
    'PC 350(a)(2)',
    'PC 350(a)',
    'PC 367f(a)',
    'PC 367f(b)',
    'PC 367g(a)',
    'PC 367g(b)',
    'PC 368(d)',
    'PC 368(e)',
    'PC 368(f)',
    'PC 374.2(a)',
    'PC 374.8(b)',
    'PC 375(a)',
    'PC 382.5',
    'PC 382.6',
    'PC 386(a)',
    'PC 386(a)',
    'PC 387(a)',
    'PC 399.5(a)',
    'PC 404.6(a)',
    'PC 405b',
    'PC 417.3',
    'PC 417.6',
    'PC 422.7',
    'PC 453(a)',
    'PC 459-460(b)', ##Research all exact code sections
    'PC 463',
    'PC 464',
    'PC 470(a)',
    'PC 470(b)',
    'PC 470(c)',
    'PC 470(d)',
    'PC 470a',
    'PC 470b',
    'PC 471',
    'PC 472',
    'PC 475(a)',
    'PC 475(b)',
    'PC 475(c)',
    'PC 476',
    'PC 478',
    'PC 477',
    'PC 478',
    'PC 479',
    'PC 478',
    'PC 480(a)',
    'PC 478',
    'PC 481',
    'PC 483.5(a)',
    'PC 484b',
    'PC 484e(a)',
    'PC 484e(b)',
    'PC 484e(d)',
    'PC 484f(a)',
    'PC 484f(b)',
    'PC 484g',
    'PC 484h(a)',
    'PC 484h(b)',
    'PC 484i(b)',
    'PC 484i(c)',
    'PC 487(a)',
    'PC 487(b)(1)(A)',
    'PC 487(b)(2)',
    'PC 487(b)(3)',
    'PC 487(c)',
    'PC 487(d)(1)',
    'PC 487a(a)',
    'PC 487a(b)',
    'PC 487b',
    'PC 487d',
    'PC 487e',
    'PC 487h(a)',
    'PC 487i',
    'PC 496(a)',
    'PC 496(b)',
    'PC 496(d)',
    'PC 496a(a)',
    'PC 496d(a)',
    'PC 499c(c)',
    'PC 499d',
    'PC 500(a)',
    'PC 502(c)(1)',
    'PC 502(c)(2)',
    'PC 502(c)(3)',
    'PC 502(c)(4)',
    'PC 502(c)(5)',
    'PC 502(c)(6)',
    'PC 502(c)(7)',
    'PC 502(c)(8)',
    'PC 504',
    'PC 504a',
    'PC 504b',
    'PC 505',
    'PC 506',
    'PC 508',
    'PC 520',
    'PC 522',
    'PC 523',
    'PC 524',
    'PC 529(a)',
    'PC 529a(a)',
    'PC 530.5(a)',
    'PC 530.5(c)(2)',
    'PC 530.5(c)(3)',
    'PC 530.5(d)(1)',
    'PC 530.5(d)(2)',
    'PC 532a(1)',
    'PC 532a(2)',
    'PC 532a(3)',
    'PC 532f(a)',
    'PC 533',
    'PC 535',
    'PC 537e(a)',
    'PC 538.5',
    'PC 548(a)',
    'PC 549',
    'PC 549',
    'PC 550(a)(1)',
    'PC 550(a)(2)',
    'PC 550(a)(3)',
    'PC 550(a)(4)',
    'PC 550(a)(5)',
    'PC 550(a)(6)',
    'PC 550(a)(7)',
    'PC 550(a)(8)',
    'PC 550(a)(9)',
    'PC 550(b)(1)',
    'PC 550(b)(2)',
    'PC 550(b)(3)',
    'PC 550(b)(4)',
    'PC 551(a)',
    'PC 551(b)',
    'PC 560',
    'PC 560.4',
    'PC 566',
    'PC 570',
    'PC 571',
    'PC 577',
    'PC 578',
    'PC 580',
    'PC 581',
    'PC 587(a)',
    'PC 587(b)',
    'PC 587.1(b)',
    'PC 591',
    'PC 593',
    'PC 594(a)(1)',
    'PC 594(a)(2)',
    'PC 594(a)(3)',
    'PC 594.3(a)',
    'PC 594.3(b)',
    'PC 594.35(a)',
    'PC 594.35(b)',
    'PC 594.35(c)',
    'PC 594.35(d)',
    'PC 594.4(a)',
    'PC 597(a)',
    'PC 597(b)',
    'PC 597(c)',
    'PC 597.5(a)(1)',
    'PC 597.5(a)(2)',
    'PC 597.5(a)(3)',
    'PC 601(a)(1)',
    'PC 601(a)(2)',
    'PC 610',
    'PC 617',
    'PC 620',
    'PC 621',
    'PC 625b(b)',
    'PC 626.9(b)',
    'PC 626.9(h)',
    'PC 626.9(i)',
    'PC 626.95(a)',
    'PC 626.10(a)(1)',
    'PC 626.10(b)',
    'PC 629.84',
    'PC 631(a)',
    'PC 636(a)',
    'PC 636(b)',
    'PC 637',
    'PC 647.6(b)',
    'PC 647.6',
    'PC 647.6',
    'PC 653f(a)',
    'PC 653f(c)',
    'PC 653f(d)(1)',
    'PC 653f(e)',
    'PC 653h(a)',
    'PC 653h(a)(1)',
    'PC 653h(a)(2)',
    'PC 653h(d)(1)',
    'PC 653h(d)(2)',
    'PC 653j(a)',
    'PC 653s(a)',
    'PC 653s(a)',
    'PC 653s(i)',
    'PC 653s(i)',
    'PC 653t(a)',
    'PC 653t(d)',
    'PC 653u(a)',
    'PC 653u(a)',
    'PC 653w(a)(1)',
    'PC 653w(a)(1)',
    'PC 664(a)',
    'PC 666(a)',
    'PC 666.5(a)',
    'PC 667.5(b)',
    'PC 836.6(a)',
    'PC 836.6(b)',
    'PC 1320(b)',
    'PC 1320.5',
    'PC 2772',
    'PC 4011.7',
    'PC 4131.5',
    'PC 4502(a)',
    'PC 4502(b)',
    'PC 4533',
    'PC 4536(a)',
    'PC 4550(a)',
    'PC 4550(b)',
    'PC 4573(a)',
    'PC 4573.6(a)',
    'PC 4573.9(a)',
    'PC 4574(a)',
    'PC 4574(b)',
    'PC 4600(a)',
    'PC 11411(c)',
    'PC 11411(d)',
    'PC 11413(a)',
    'PC 11418(a)(1)',
    'PC 11418(a)(2)',
    'PC 11419(a)',
    'PC 12022(a)(1)',
    'PC 12022(a)(2)',
    'PC 12022(c)',
    'PC 12022(d)',
    'PC 12035(b)(1)',
    'PC 12040(a)',
    'PC 12072(a)(1)',
    'PC 12072(a)(2)',
    'PC 12072(a)(3)',
    'PC 12072(a)(4)',
    'PC 12072(a)(5)',
    'PC 12072(b)',
    'PC 12072(b)',
    'PC 12072(c)(1)',
    'PC 12072(c)(3)',
    'PC 12072(c)(4)',
    'PC 12072(c)(5)',
    'PC 12072(c)(6)',
    'PC 12072(d)',
    'PC 12072(e)',
    'PC 12072(g)(4)',
    'PC 12072(g)(2)',
    'PC 12076(b)(1)',
    'PC 12076(c)(1)',
    'PC 12090',
    'PC 12101(a)(1)',
    'PC 12101',
    'PC 12220(a)',
    'PC 12220(b)',
    'PC 12280(a)(1)',
    'PC 12280(a)(2)',
    'PC 12280(b)',
    'PC 12303.3',
    'PC 12303.6',
    'PC 12304',
    'PC 12312',
    'PC 12320',
    'PC 12355(a)',
    'PC 12355(b)',
    'PC 12370',
    'PC 12403.7(g)',
    'PC 12422',
    'PC 12520',
    'PC 18715(a)',
    'PC 18720',
    'PC 18725',
    'PC 18730',
    'PC 18735(a)',
    'PC 18740',
    'PC 20110(a)',
    'PC 20110(b)',
    'PC 22810(g)(1)',
    'PC 22810(g)(2)',
    'PC 22910',
    'PC 23900',
    'PC 25110',
    'PC 25300(a)',
    'PC 25400(a)',
    'PC 25400(a)',
    'PC 25850',
    'PC 27500(a)',
    'PC 27500(b)',
    'PC 27500(b)',
    'PC 27510',
    'PC 27510',
    'PC 27510',
    'PC 27515',
    'PC 27520',
    'PC 27540(a)',
    'PC 27540(c)',
    'PC 27540(d)',
    'PC 27540(e)',
    'PC 27540(f)',
    'PC 27545',
    'PC 27550',
    'PC 27590(b)',
    'PC 27590(b)',
    'PC 28250(b)',
    'PC 29700',
    'PC 30315',
    'PC 30600(a)',
    'PC 30600(b)',
    'PC 30605',
    'PC 30720',
    'PC 31360',
    'PC 32625(a)',
    'PC 32625(b)',
    'PC 33410'
  ]
end
