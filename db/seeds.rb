#shipping_methods = ShippingMethod.create([
#  {shipping_calculator_id: 1, name: "Ground", rate: 0.0}
#])
#shipping_calculators = ShippingCalculator.create([
#  {name: "Flat", calculation_method: "flat"}
#])
#categories = Category.create([
#  {name: "Office Supplies", slug: "office-supplies", description: "Shop Office Supplies"},
#  {name: "Ink & Toner", slug: "ink-and-toner", description: "Shop Ink & Toner"},
#  {name: "Breakroom & Janitorial", slug: "breakroom-and-janetorial", description: "Shop Breakroom and Janetorial Supplies"},
#  {name: "Office Technology", slug: "technology", description: "Shop Office Technology"},
#  {name: "Office Furniture", slug: "office-furniture", description: "Shop Office Furniture"}
#])
#items = Item.create([
#  {category_id: 1, number: "TN450COMP", name: "Brother® TN450 Compatible Toner", slug: "brother-tn450-compatible-toner", price: 49.99, sale_price: 39.99, cost_price: 21.95},
#  {category_id: 1, number: "TN750COMP", name: "Brother® TN750 Compatible Toner", slug: "brother-tn750-compatible-toner", price: 59.99, sale_price: 49.99, cost_price: 29.95},
#  {category_id: 1, number: "CE285ACOMP", name: "HP® 85A (CE285A) Compatible Toner", slug: "hp-85a-compatible-toner", price: 44.99, sale_price: 34.99, cost_price: 19.95},
#  {category_id: 1, number: "UNV21200", name: "Universal® White Copy Paper, (8.5 x 11, 20 lbs, 92 Bright, 5000/Carton)", slug: "universal-white-copy-paper", price: 44.99, sale_price: 39.99, cost_price: 37.95},
#])
#users = User.create([
#  {email: "admin@247officesupply.com", password: "#copiers247", created_at: Time.now},
#  {email: "jbarnes@sw-ro.com", password: "#SW2016#jb", created_at: Time.now},
#  {email: "dgimpel@cahokianrc.com", password: "#SW2016#dg", created_at: Time.now},
#  {email: "cguthrie@caseyvillenrc.com", password: "#SW2016#cg", created_at: Time.now},
#  {email: "tswanson@beauvaismanor.com", password: "#SW2016#ts", created_at: Time.now},
#  {email: "ckelley@ranchomanor.com", password: "#SW2016#ck", created_at: Time.now},
#  {email: "janderson@hillsidemanorhc.com", password: "#SW2016#ja", created_at: Time.now},
#  {email: "dbogert@thegroves.com", password: "#SW2016#db", created_at: Time.now},
#  {email: "dlundquist@gchospice.net", password: "#SW2016#dl", created_at: Time.now},
#  {email: "jcarneal@seasonscarecenter.com", password: "#SW2016#jc", created_at: Time.now},
#  {email: "moeherman@gmail.com", password: "#SW2016#mh", created_at: Time.now},
#  {email: "arleth@towerhillhealthcare.com", password: "#SW2016#ab", created_at: Time.now},
#  {email: "bom@carriagesquarehealth.com", password: "#SW2016#jb", created_at: Time.now},
#  {email: "sreed@linnlrc.com", password: "#SW2016#sr", created_at: Time.now},
#   LEGACY LOGINS
#  {email: "snease@wbp-hc.com", password: "#LH2016#sn", created_at: Time.now},
#  {email: "cpruszko@groveatlincolnpark.com", password: "#LH2016#cp", created_at: Time.now},
#  {email: "ksimpson@astoriaplace.com", password: "#LH2016#ks", created_at: Time.now},
#  {email: "saburahmuh@thegroveofevanston.com", password: "#LH2016#sa", created_at: Time.now},
#  {email: "bcole@chaletliving.com", password: "#LH2016#bc", created_at: Time.now},
#])
#accounts = Account.create([
#  {user_id: User.find_by(email: "jbarnes@sw-ro.com").id, name: "SW Financial - Regional Office", email: "jbarnes@sw-ro.com", ship_to_address_1: "1 Annable Court", ship_to_address_2: nil, ship_to_city: "Cahokia", ship_to_state: "IL", ship_to_zip: "62206", ship_to_phone: "(618) 332-0617", ship_to_fax: "(618) 332-8537", active: true},
#  {user_id: User.find_by(email: "dgimpel@cahokianrc.com").id, name: "Cahokia Nursing and Rehabilitation Center", email: "dgimpel@cahokianrc.com", ship_to_address_1: "2 Annable Court", ship_to_address_2: nil, ship_to_city: "Cahokia", ship_to_state: "IL", ship_to_zip: "62206", ship_to_phone: "(618) 332-0114", ship_to_fax: "(618) 332-1043", active: true},
#  {user_id: User.find_by(email: "cguthrie@caseyvillenrc.com").id, name: "Caseyville Nursing and Rehabilitation Center", email: "cguthrie@caseyvillenrc.com", ship_to_address_1: "601 West Lincoln", ship_to_address_2: nil, ship_to_city: "Caseyville", ship_to_state: "IL", ship_to_zip: "62232", ship_to_phone: "(618) 345-3072", ship_to_fax: "(618) 345-3170", active: true},
#  {user_id: User.find_by(email: "tswanson@beauvaismanor.com").id, name: "Beauvais Healthcare & Rehab Center", email: "tswanson@beauvaismanor.com", ship_to_address_1: "3625 Magnolia Avenue", ship_to_address_2: nil, ship_to_city: "Saint Louis", ship_to_state: "MO", ship_to_zip: "63110", ship_to_phone: "(314) 771-2990", ship_to_fax: "(314) 771-7960", active: true},
#  {user_id: User.find_by(email: "ckelley@ranchomanor.com").id, name: "Rancho Manor Healthcare and Rehab Center", email: "ckelley@ranchomanor.com", ship_to_address_1: "615 Rancho Lane", ship_to_address_2: nil, ship_to_city: "Florissant", ship_to_state: "MO", ship_to_zip: "63031", ship_to_phone: "(314) 839-2150", ship_to_fax: "(314) 839-8736", active: true},
#  {user_id: User.find_by(email: "janderson@hillsidemanorhc.com").id, name: "Hillside Manor Healthcare and Rehab Center", email: "janderson@hillsidemanorhc.com", ship_to_address_1: "1265 McLaran Ave.", ship_to_address_2: nil, ship_to_city: "Saint Louis", ship_to_state: "MO", ship_to_zip: "63147", ship_to_phone: "(314) 388-4121", ship_to_fax: "(314) 388-5926", active: true},
#  {user_id: User.find_by(email: "dbogert@thegroves.com").id, name: "The Groves, Forest View, White Oak, Rosewood", email: "dbogert@thegroves.com", ship_to_address_1: "1515 W. White Oak	", ship_to_address_2: nil, ship_to_city: "Independence", ship_to_state: "MO", ship_to_zip: "64050", ship_to_phone: "(816) 254-3500", ship_to_fax: "(816) 521-4930", active: true},
#  {user_id: User.find_by(email: "dlundquist@gchospice.net").id, name: "Groves Community Hospice", email: "dlundquist@gchospice.net", ship_to_address_1: "15600 Woods Chapel Road", ship_to_address_2: "Suite A", ship_to_city: "Kansas City", ship_to_state: "MO", ship_to_zip: "64139", ship_to_phone: "(816) 836-1096", ship_to_fax: "(816) 521-4737", active: true},
#  {user_id: User.find_by(email: "jcarneal@seasonscarecenter.com").id, name: "Seasons Care Center", email: "jcarneal@seasonscarecenter.com", ship_to_address_1: "15600 Woods Chapel Road", ship_to_address_2: nil, ship_to_city: "Kansas City", ship_to_state: "MO", ship_to_zip: "64139", ship_to_phone: "(816) 478-4757", ship_to_fax: "(816) 478-8338", active: true},
#  {user_id: User.find_by(email: "bom@carriagesquarehealth.com").id, name: "Carriage Square Living & Rehab Center", email: "bom@carriagesquarehealth.com", ship_to_address_1: "4009 Gene Field Road", ship_to_address_2: nil, ship_to_city: "Saint Joseph", ship_to_state: "MO", ship_to_zip: "64506", ship_to_phone: "(816) 364-1526", ship_to_fax: "(816) 364-2632", active: true},
#  {user_id: User.find_by(email: "sreed@linnlrc.com").id, name: "Linn Living and Rehab Center", email: "sreed@linnlrc.com", ship_to_address_1: "196 Hwy, CC", ship_to_address_2: nil, ship_to_city: "Linn", ship_to_state: "MO", ship_to_zip: "65051", ship_to_phone: "(573) 897-0700", ship_to_fax: "(573) 897-0400", active: true},
#  {user_id: User.find_by(email: "moeherman@gmail.com").id, name: "Franklin Grove Living & Rehab Center", email: "moeherman@gmail.com", ship_to_address_1: "502 North State Street", ship_to_address_2: nil, ship_to_city: "Franklin Grove", ship_to_state: "IL", ship_to_zip: "61031", ship_to_phone: "(815) 456-2374", ship_to_fax: "(815) 456-2250", active: true},
#  {user_id: User.find_by(email: "arleth@towerhillhealthcare.com").id, name: "Tower Hill Healthcare Center", email: "arleth@towerhillhealthcare.com", ship_to_address_1: "759 Kane Street", ship_to_address_2: nil, ship_to_city: "South Elgin", ship_to_state: "IL", ship_to_zip: "60177", ship_to_phone: "(847) 697-3310", ship_to_fax: "(847) 697-3354", active: true},
# LEGACY ACCOUNTS
#  {user_id: User.find_by(email: "snease@wbp-hc.com").id, name: "Warren Bar Gold Coast", email: "snease@wbp-hc.com", ship_to_address_1: "66 West Oak Street", ship_to_address_2: nil, ship_to_city: "Chicago", ship_to_state: "IL", ship_to_zip: "60616", ship_to_phone: "(312) 705-5100", ship_to_fax: nil, active: true},
#  {user_id: User.find_by(email: "cpruszko@groveatlincolnpark.com").id, name: "The Grove At Lincoln Park", email: "cpruszko@groveatlincolnpark.com", ship_to_address_1: "2732 N Hampden Court", ship_to_address_2: nil, ship_to_city: "Chicago", ship_to_state: "IL", ship_to_zip: "60614", ship_to_phone: "(773) 248-6000", ship_to_fax: nil, active: true},
#  {user_id: User.find_by(email: "ksimpson@astoriaplace.com").id, name: "Astoria Place Living & Rehab Center", email: "ksimpson@astoriaplace.com", ship_to_address_1: "6300 N California Avenue", ship_to_address_2: nil, ship_to_city: "Chicago", ship_to_state: "IL", ship_to_zip: " 60659", ship_to_phone: "(773) 973-1900", ship_to_fax: nil, active: true},
#  {user_id: User.find_by(email: "saburahmuh@thegroveofevanston.com").id, name: "The Grove Of Evanston", email: "saburahmuh@thegroveofevanston.com", ship_to_address_1: "500 Asbury Street", ship_to_address_2: nil, ship_to_city: "Evanston", ship_to_state: "IL", ship_to_zip: " 60202", ship_to_phone: "(847) 316-3320", ship_to_fax: nil, active: true},
#  {user_id: User.find_by(email: "bcole@chaletliving.com").id, name: "Chalet Living & Rehab Center", email: "bcole@chaletliving.com", ship_to_address_1: "7350 North Sheridan Road", ship_to_address_2: nil, ship_to_city: "Chicago", ship_to_state: "IL", ship_to_zip: " 60626", ship_to_phone: "(773) 274-1000", ship_to_fax: nil, active: true},
#])
#a = Account.find_by(name: "The Groves, Forest View, White Oak, Rosewood")
#Order.create({id: 2, number: "ORD10001", account_id: a.id, completed_at: Date.parse('January 5th 2016').to_s, ship_to_account_name: a.name, ship_to_address_1: a.ship_to_address_1, ship_to_address_2: a.ship_to_address_2, ship_to_city: a.ship_to_city, ship_to_state: a.ship_to_state, ship_to_zip: a.ship_to_zip, ship_to_phone: a.ship_to_phone, notes: "Entered by M.H."})
#Item.create({number: "BRTN331C", name: "Brother TN331C Toner Cartridge Cyan", price: 84.95, cost_price: 50.51, slug: "BRTN331C"})
# OrderLineItem.create({order_id: 2, order_line_number: 1, item_id: Item.find_by(number: "CNM5207B001").id, quantity: 3,  price: "20.11"})
# OrderLineItem.create({order_id: 2, order_line_number: 2, item_id: Item.find_by(number: "HPCC364ACOMP").id, quantity: 1,  price: "80.85"})
# User.create(email: "ttoner@aperioncare.com", password: "#AH2016tt", created_at: Time.now)
# User.create(email: "r2@aperioncare.com", password: "#AH2016r2", created_at: Time.now)
# User.create(email: "kshoemaker@aperioncare.com", password: "#AH2016ks", created_at: Time.now)
# User.create(email: "pash@aperioncare.com", password: "#AH2016pa", created_at: Time.now)
# User.create(email: "aabiola@aperioncare.com", password: "#AH2016aa", created_at: Time.now)
# User.create(email: "jtucker@aperioncare.com", password: "#AH2016jt", created_at: Time.now)
# User.create(email: "kmartin2@aperioncare.com", password: "#AH2016km", created_at: Time.now)
# User.create(email: "mthomas@aperioncare.com", password: "#AH2016mt", created_at: Time.now)
# User.create(email: "nray@aperioncare.com", password: "#AH2016nr", created_at: Time.now)
# User.create(email: "climons@aperioncare.com", password: "#AH2016cl", created_at: Time.now)
# User.create(email: "jgasca@aperioncare.com", password: "#AH2016jg", created_at: Time.now)
# User.create(email: "meirk@aperioncare.com", password: "#AH2016me", created_at: Time.now)
# User.create(email: "edaniel@aperioncare.com", password: "#AH2016ed", created_at: Time.now)
# User.create(email: "namundson@aperioncare.com", password: "#AH2016na", created_at: Time.now)
# User.create(email: "jmartines@aperioncare.com", password: "#AH2016jm", created_at: Time.now)
# User.create(email: "sprice@aperioncare.com", password: "#AH2016sp", created_at: Time.now)
# User.create(email: "vimbierowicz@aperioncare.com", password: "#AH2016vi", created_at: Time.now)
# User.create(email: "akindernay@aperioncare.com", password: "#AH2016ak", created_at: Time.now)
# User.create(email: "preceptionist@aperioncare.com", password: "#AH2016pr", created_at: Time.now)
# User.create(email: "dsoto@aperioncare.com", password: "#AH2016ds", created_at: Time.now)
# User.create(email: "bcappis@aperioncare.com", password: "#AH2016bc", created_at: Time.now)
# User.create(email: "pbero@aperioncare.com", password: "#AH2016pb", created_at: Time.now)
# User.create(email: "rthompson@aperioncare.com", password: "#AH2016rt", created_at: Time.now)
# User.create(email: "Thamilton@aperioncare.com", password: "#AH2016Th", created_at: Time.now)
# User.create(email: "pmangiaracina@aperioncare.com", password: "#AH2016pm", created_at: Time.now)
# User.create(email: "nbreyfogle@aperioncare.com", password: "#AH2016nb", created_at: Time.now)
# User.create(email: "acarter@aperioncare.com", password: "#AH2016ac", created_at: Time.now)
# User.create(email: "lhartney@aperioncare.com", password: "#AH2016lh", created_at: Time.now)
# User.create(email: "lvancil@aperioncare.com", password: "#AH2016lv", created_at: Time.now)
# User.create(email: "egreception@villahc.com", password: "#VH2016eg", created_at: Time.now)
# User.create(email: "lisrael@villahc.com", password: "#VH2016li", created_at: Time.now)
# Account.create(name: "The Villa at Evergreen Par", ship_to_address_1: "10124 South Kedzie Avenue", ship_to_city: " Evergreen Park", ship_to_state: "IL", ship_to_zip: "60804", email: "egreception@villahc.com", user_id: User.find_by(email: "egreception@villahc.com"))
# UserAccount.create(user_id: User.find_by(email: "lisrael@villahc.com").id, account_id: Account.find_by(email: "egreception@villahc.com").id)
# Account.create(name: "Aperion Care Amboy", ship_to_address_1: "15 W Wasson Road", ship_to_city: "Amboy", ship_to_state: "IL", ship_to_zip: "61310", ship_to_phone: "(815) 857-2550", ship_to_fax: "(815) 857-4016", user_id: User.find_by(email: "ttoner@aperioncare.com"), email: "ttoner@aperioncare.com")
# Account.create(name: "Aperion Care Arbors At Michigan City", ship_to_address_1: "1101 East Coolspring Avenue", ship_to_city: "Michigan City", ship_to_state: "IN", ship_to_zip: "46360", ship_to_phone: "(219) 874-5211", ship_to_fax: "(219) 872-6253", user_id: User.find_by(email: "r2@aperioncare.com"), email: "r2@aperioncare.com")
# Account.create(name: "Aperion Care Bloomington", ship_to_address_1: "1509 N Calhoun Street",  ship_to_city: "Bloomington", ship_to_state: "IL", ship_to_zip: "61701", ship_to_phone: "(309) 827-6046", user_id: User.find_by(email: "kshoemaker@aperioncare.com"), email: "kshoemaker@aperioncare.com")
# Account.create(name: "Aperion Care Bridgeport", ship_to_address_1: "900 East Corporation Street", ship_to_city: "Bridgeport", ship_to_state: "IL", ship_to_zip: "62417", ship_to_phone: "(618) 945-2091", ship_to_fax: "(618) 945-9017", user_id: User.find_by(email: "pash@aperioncare.com"), email: "pash@aperioncare.com")
# Account.create(name: "Aperion Care Burbank", ship_to_address_1: "5701 W 79th Street", ship_to_city: "Burbank", ship_to_state: "IL", ship_to_zip: "60459", ship_to_phone: "(708) 499-5400", ship_to_fax: "(708) 499-5472", user_id: User.find_by(email: "aabiola@aperioncare.com"), email: "aabiola@aperioncare.com")
# Account.create(name: "Aperion Care Chicago Heights", ship_to_address_1: "490 W 16th Place", ship_to_city: "Chicago Heights", ship_to_state: "IL", ship_to_zip: "60411", ship_to_phone: "(708) 481-4444", ship_to_fax: "(708) 481-4606", user_id: User.find_by(email: "jtucker@aperioncare.com"), email: "jtucker@aperioncare.com")
# Account.create(name: "Aperion Care Colfax", ship_to_address_1: "402 South Harrison Street", ship_to_city: "Colfax", ship_to_state: "IL", ship_to_zip: "61278", ship_to_phone: "(309) 723-2591", user_id: User.find_by(email: "kmartin2@aperioncare.com"), email: "kmartin2@aperioncare.com")
# Account.create(name: "Aperion Care Decatur", ship_to_address_1: "2650 N Monroe Street", ship_to_city: "Decatur", ship_to_state: "IL", ship_to_zip: "62526", ship_to_phone: "(217) 875-1973", ship_to_fax: "(217) 875-5513", user_id: User.find_by(email: "mthomas@aperioncare.com"), email: "mthomas@aperioncare.com")
# Account.create(name: "Aperion Care Demotte", ship_to_address_1: "10352 North 600 East", ship_to_city: "Demotte", ship_to_state: "IN", ship_to_zip: "46310", ship_to_phone: "(219) 345-5211", ship_to_fax: "(219) 345-4949", user_id: User.find_by(email: "nray@aperioncare.com"), email: "nray@aperioncare.com")
# Account.create(name: "Aperion Care Dolton", ship_to_address_1: "14325 S Blackstone Avenue", ship_to_city: "Dolton", ship_to_state: "IL", ship_to_zip: "60419", ship_to_phone: "(708) 849-5000", ship_to_fax: "(708) 849-3190", user_id: User.find_by(email: "climons@aperioncare.com"), email: "climons@aperioncare.com")
# Account.create(name: "Aperion Care Elgin", ship_to_address_1: "134 N McLean Blvd", ship_to_city: "Elgin"  , ship_to_state: "IL", ship_to_zip: "60123", ship_to_phone: "(847) 742-8822", user_id: User.find_by(email: "jgasca@aperioncare.com"), email: "jgasca@aperioncare.com")
# Account.create(name: "Aperion Care Evanston", ship_to_address_1: "1300 Oak Avenue", ship_to_city: "Evanston", ship_to_state: "IL", ship_to_zip: "60201", ship_to_phone: "(847) 869-1300", ship_to_fax: "(847) 869-1378", user_id: User.find_by(email: "meirk@aperioncare.com"), email: "meirk@aperioncare.com")
# Account.create(name: "Aperion Care Forest Park", ship_to_address_1: "8200 W. Roosevelt Road", ship_to_city: "Forest Park", ship_to_state: "IL", ship_to_zip: "60130", ship_to_phone: "(708) 488-9850", ship_to_fax: "(708) 488-9870", user_id: User.find_by(email: "edaniel@aperioncare.com"), email: "edaniel@aperioncare.com")
# Account.create(name: "Aperion Care Hidden Lake", ship_to_address_1: "11728 Hidden Lake Drive", ship_to_city: "St Louis", ship_to_state: "MO", ship_to_zip: "63138", ship_to_phone: "(314) 355-8833", user_id: User.find_by(email: "namundson@aperioncare.com"), email: "namundson@aperioncare.com")
# Account.create(name: "Aperion Care Highwood", ship_to_address_1: "50 Pleasant Avenue", ship_to_city: "Highwood", ship_to_state: "IL", ship_to_zip: "60040", ship_to_phone: "(847) 432-9142", ship_to_fax: "(847) 432-4740")
# Account.create(name: "Aperion Care International", ship_to_address_1: "4815 S Western Blvd", ship_to_city: "Chicago", ship_to_state: "IL", ship_to_zip: "60609", ship_to_phone: "(773) 927-4200", ship_to_fax: "(773) 927-1287", user_id: User.find_by(email: "jmartines@aperioncare.com"), email: "jmartines@aperioncare.com")
# Account.create(name: "Aperion Care Jacksonville", ship_to_address_1: "1021 North Church Street", ship_to_city: "Jacksonville", ship_to_state: "IL", ship_to_zip: "62650", ship_to_phone: "(217) 245-4174", ship_to_fax: "(217) 243-5901", user_id: User.find_by(email: "sprice@aperioncare.com"), email: "sprice@aperioncare.com")
# Account.create(name: "Aperion Care Kokomo", ship_to_address_1: "3518 S LaFountain Street", ship_to_city: "Kokomo", ship_to_state: "IN", ship_to_zip: "46902", ship_to_phone: "(765) 453-4666", ship_to_fax: "(765) 453-0358", user_id: User.find_by(email: "vimbierowicz@aperioncare.com"), email: "vimbierowicz@aperioncare.com")
# Account.create(name: "Aperion Care Litchfield", ship_to_address_1: "1024 East Tyler Avenue", ship_to_city: "Litchfield", ship_to_state: "IL", ship_to_zip: "62056", ship_to_phone: "(217) 324-3842", ship_to_fax: "(217) 324-5482", user_id: User.find_by(email: "akindernay@aperioncare.com"), email: "akindernay@aperioncare.com")
# Account.create(name: "Aperion Care Midlothian", ship_to_address_1: "3249 W. 147th Street", ship_to_city: "Midlothian", ship_to_state: "IL", ship_to_zip: "60445", ship_to_phone: "(708) 389-3141", ship_to_fax: "(708) 396-1626", user_id: User.find_by(email: "preceptionist@aperioncare.com"), email: "preceptionist@aperioncare.com")
# Account.create(name: "Aperion Care Oak Lawn", ship_to_address_1: "9401 South Ridgeland Avenue", ship_to_city: "Oak Lawn", ship_to_state: "IL", ship_to_zip: "60453", ship_to_phone: "(708) 599-6700", ship_to_fax: "(708) 599-6258", user_id: User.find_by(email: "dsoto@aperioncare.com"), email: "dsoto@aperioncare.com")
# Account.create(name: "Aperion Care Peru", ship_to_address_1: "1850 W Matador Street", ship_to_city: "Peru", ship_to_state: "IN", ship_to_zip: "46970", ship_to_phone: "(765) 689-5000", ship_to_fax: "(765) 689-5711", user_id: User.find_by(email: "bcappis@aperioncare.com"), email: "bcappis@aperioncare.com")
# Account.create(name: "Aperion Care Plum Grove", ship_to_address_1: "24 South Plum Grove Drive", ship_to_city: "Palatine", ship_to_state: "IL", ship_to_zip: "60067", ship_to_phone: "(847) 358-0311", ship_to_fax: "(847) 358-8875", user_id: User.find_by(email: "pbero@aperioncare.com"), email: "pbero@aperioncare.com")
# Account.create(name: "Aperion Care Spring Valley", ship_to_address_1: "1300 N Greenwood Street", ship_to_city: "Spring Valley", ship_to_state: "IL", ship_to_zip: "61632", ship_to_phone: "(815) 664-4708", user_id: User.find_by(email: "rthompson@aperioncare.com"), email: "rthompson@aperioncare.com")
# Account.create(name: "Aperion Care Springfield", ship_to_address_1: "525 S Martin Luther King Drive", ship_to_city: "Springfield", ship_to_state: "IL", ship_to_zip: "62703", ship_to_phone: "(217) 789-1680", ship_to_fax: "(217) 789-0842", user_id: User.find_by(email: "Thamilton@aperioncare.com"), email: "Thamilton@aperioncare.com")
# Account.create(name: "Aperion Care St Elmo", ship_to_address_1: "221 East Cumberland Rd Street", ship_to_city: "Elmo", ship_to_state: "IL", ship_to_zip: "62458", ship_to_phone: "(618) 829-5551", ship_to_fax: "(618) 829-5569")
# Account.create(name: "Aperion Care Tolleston Park", ship_to_address_1: "2350 Taft Street", ship_to_city: "Gary", ship_to_state: "IN", ship_to_zip: "46404", ship_to_phone: "(219) 944-2677", ship_to_fax: "(219) 977-2602", user_id: User.find_by(email: "pmangiaracina@aperioncare.com"), email: "pmangiaracina@aperioncare.com")
# Account.create(name: "Aperion Care Toluca", ship_to_address_1: "101 East Via Ghiglieri", ship_to_city: "Toluca", ship_to_state: "IL", ship_to_zip: "61369", ship_to_phone: "(815) 452-2367")
# Account.create(name: "Aperion Care Valparaiso", ship_to_address_1: "3301 Calumet Avenue", ship_to_city: "Valparaiso", ship_to_state: "IN", ship_to_zip: "46383", ship_to_phone: "(219) 462-0508", user_id: User.find_by(email: "nbreyfogle@aperioncare.com"), email: "nbreyfogle@aperioncare.com")
# Account.create(name: "Aperion Care Willmington", ship_to_address_1: "555 W Kahler Road", ship_to_city: "Wilmington", ship_to_state: "IL", ship_to_zip: "60481", ship_to_phone: "(815) 476-2200", ship_to_fax: "(815) 476-7939", user_id: User.find_by(email: "acarter@aperioncare.com"), email: "acarter@aperioncare.com")
# Account.create(name: "Aperion Estates Peru", ship_to_address_1: "1200 KittyHawk", ship_to_city: "Peru", ship_to_state: "IN", ship_to_zip: "46970", ship_to_phone: "(765) 689-7305", ship_to_fax: "(765) 689-7333", user_id: User.find_by(email: "lhartney@aperioncare.com"), email: "lhartney@aperioncare.com")
# Account.create(name: "Renewal Rehab LLC", ship_to_address_1: "8131 N Monticello Avenue", ship_to_city: "Skokie", ship_to_state: "IL", ship_to_zip: "60076", ship_to_phone: "(847) 673-6767", ship_to_fax: "(847) 673-6768")
# Account.create(name: "River Crossing Rehab", ship_to_address_1: "1145 Frank Street", ship_to_city: "Galesburg", ship_to_state: "IL", ship_to_zip: "61401", ship_to_phone: "(309) 342-2103", ship_to_fax: "(309) 342-1819", user_id: User.find_by(email: "lvancil@aperioncare.com"), email: "lvancil@aperioncare.com")
# Account.create(name: "Riverwood Rehab", ship_to_address_1: "430 30th Avenue", ship_to_city: "East Moline", ship_to_state: "IL", ship_to_zip: "61244", ship_to_phone: "(309) 755-3466", ship_to_fax: "(309) 755-6670", user_id: User.find_by(email: "sdyer@aperioncare.com"), email: "sdyer@aperioncare.com")