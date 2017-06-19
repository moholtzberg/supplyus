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

# categories = Category.create([
#  {name: "test 1", slug: "inks-toners", description: "Shop Office Supplies"}
# ])

#items = Item.create([
#  {category_id: 1, number: "TN450COMP", name: "Brother® TN450 Compatible Toner", slug: "brother-tn450-compatible-toner", price: 49.99, sale_price: 39.99, cost_price: 21.95},
#  {category_id: 1, number: "TN750COMP", name: "Brother® TN750 Compatible Toner", slug: "brother-tn750-compatible-toner", price: 59.99, sale_price: 49.99, cost_price: 29.95},
#  {category_id: 1, number: "CE285ACOMP", name: "HP® 85A (CE285A) Compatible Toner", slug: "hp-85a-compatible-toner", price: 44.99, sale_price: 34.99, cost_price: 19.95},
#  {category_id: 1, number: "UNV21200", name: "Universal® White Copy Paper, (8.5 x 11, 20 lbs, 92 Bright, 5000/Carton)", slug: "universal-white-copy-paper", price: 44.99, sale_price: 39.99, cost_price: 37.95},
#])

Item.where(id: 5000..5500).map {|a| File.open('some-file.txt', 'a') { |f| f.write("i = Item.create(number: \"#{a.number}\", name: \"#{a.name}\", description: \"#{a.description}\", price: \"#{a.price}\", active: \"#{a.active}\")\n")}; 
  i.item_properties.map {|s| File.open('some-file.txt', 'a') { |f| f.write("s = ItemPropery.create(item_id: \"#{s.item_id}\", key: \"#{s.key}\", value: \"#{s.value}\", order: \"#{s.order}\", active: \"#{s.active}\", type: \"#{s.type}\")\n")}}
  i.item_categories.map {|c| File.open('some-file.txt', 'a') { |f| f.write("c = ItemCategory.create(item_id: \"#{c.item_id}\", category_id: \"#{c.category_id}\")\n")}}
}