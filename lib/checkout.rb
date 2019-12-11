# frozen_string_literal: true

# Checkout implements the checkout interface
class Checkout
  attr_reader :items_count

  def initialize(promotion_rules = {})
    @promotion_rules = promotion_rules
    @items = []
    @items_count = 0
  end

  def scan(item)
    found_item = find_by_code(item.code)
    if found_item
      found_item[:quantity] += 1
    else
      @items << { data: item, quantity: 1 }
    end

    @items_count += 1
  end

  def find_by_code(code)
    @items.find { |item| item[:data].code == code }
  end
end
