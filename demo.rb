# frozen_string_literal: true

require 'ostruct'
require_relative 'lib/checkout'
require_relative 'lib/promotion'

promotion_rules = {
  'on_total' => {
    'min_amount' => 60,
    'discount' => 10,
    'discount_type' => 'percent'
  },
  'on_item' => {
    '001' => {
      'min_quantity' => 2,
      'discount_type' => 'promo_price',
      'promo_price' => 8.5
    }
  }
}

item1 = OpenStruct.new(
  code: '001',
  name: 'Lavender heart',
  price: 9.25
)
item2 = OpenStruct.new(
  code: '002',
  name: 'Personalised cufflinks',
  price: 45.00
)
item3 = OpenStruct.new(
  code: '003',
  name: 'Kids T-shirts',
  price: 19.95
)

puts 'Test data'
puts '---------'

# test case 1
co = Checkout.new(promotion_rules)
basket = [item1, item2, item3]
basket.each { |item| co.scan(item) }
price = co.total
puts "Basket: #{basket.map(&:code).join(',')}"
puts "Total price expected: £#{price}\n\n"

# test case 2
co = Checkout.new(promotion_rules)
basket = [item1, item3, item1]
basket.each { |item| co.scan(item) }
price = co.total
puts "Basket: #{basket.map(&:code).join(',')}"
puts "Total price expected: £#{price}\n\n"

# test case 3
co = Checkout.new(promotion_rules)
basket = [item1, item2, item1, item3]
basket.each { |item| co.scan(item) }
price = co.total
puts "Basket: #{basket.map(&:code).join(',')}"
puts "Total price expected: £#{price}\n\n"
