# frozen_string_literal: true

# Promotion implements the promotion interface
class Promotion
  def initialize(promotion_rules)
    @rules = promotion_rules
  end

  def discounted_total(total)
    return total if total < @rules['on_total']['min_amount']

    case @rules['on_total']['discount_type']
    when 'percent'
      discount = total * @rules['on_total']['discount'] / 100
      (total - discount).round(2)
    when 'value'
      total - @rules['on_total']['discount']
    else
      total
    end
  end

  def discounted_price(item_code, price, quantity)
    item_promo_rules = @rules['on_item'][item_code]

    unless item_promo_rules && quantity >= item_promo_rules['min_quantity']
      return price
    end

    case item_promo_rules['discount_type']
    when 'promo_price'
      item_promo_rules['promo_price']
    else
      price
    end
  end
end
