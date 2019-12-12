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

  def total
    @promotion = Promotion.new(@promotion_rules) unless @promotion_rules.empty?

    total = @items.inject(0) { |sum, item| sum + total_item_price(item) }
    discounted_total(total)
  end

  private

  def total_item_price(item)
    item_price = item[:data].price

    if @promotion
      item_price = @promotion.discounted_price(
        item[:data].code,
        item_price,
        item[:quantity]
      )
    end

    item_price * item[:quantity]
  end

  def discounted_total(total)
    if @promotion
      @promotion.discounted_total(total)
    else
      total
    end
  end
end
