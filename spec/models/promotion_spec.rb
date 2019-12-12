# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/promotion'

describe Promotion do
  let(:rules1) do
    {
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
        },
        '002' => {
          'min_quantity' => 2,
          'discount_type' => 'unknown',
          'promo_price' => 7.5
        }
      }
    }
  end

  let(:rules2) do
    {
      'on_total' => {
        'min_amount' => 80,
        'discount' => 5,
        'discount_type' => 'value'
      },
      'on_item' => {
        '003' => {
          'min_quantity' => 2,
          'discount_type' => 'promo_price',
          'promo_price' => 40
        },
        '004' => {
          'min_quantity' => 3,
          'discount_type' => 'promo_price',
          'promo_price' => 15
        }
      }
    }
  end

  describe '#discounted_total' do
    let(:discounted_total) { promotion.discounted_total(total) }

    context 'discount type is percent' do
      let(:promotion) { Promotion.new(rules1) }

      context 'total is smaller than the min amount' do
        let(:total) { 59 }

        it 'returns the original total' do
          expect(discounted_total).to eq(total)
        end
      end

      context 'total meets the min amount' do
        let(:total) { 60 }

        it 'returns the percent discounted total' do
          expect(discounted_total).to eq(54)
        end
      end
    end

    context 'discount type is value' do
      let(:promotion) { Promotion.new(rules2) }

      context 'total is smaller than the min amount' do
        let(:total) { 79 }

        it 'returns the original total' do
          expect(discounted_total).to eq(total)
        end
      end

      context 'total meets the min amount' do
        let(:total) { 80 }

        it 'returns the value discounted total' do
          expect(discounted_total).to eq(75)
        end
      end
    end
  end

  describe '#discounted_price' do
    let(:promotion) { Promotion.new(rules1) }
    let(:discounted) { promotion.discounted_price(item_code, price, quantity) }

    context 'item promo rules not found' do
      let(:item_code) { '00X' }
      let(:price) { 30 }
      let(:quantity) { 1 }

      it 'returns the original price' do
        expect(discounted).to eq(price)
      end
    end

    context 'items quantity is smaller than the min quantity' do
      let(:item_code) { '001' }
      let(:price) { 30 }
      let(:quantity) { 1 }

      it 'returns the original price' do
        expect(discounted).to eq(price)
      end
    end

    context 'discount type is promo price' do
      let(:item_code) { '001' }
      let(:price) { 30 }
      let(:quantity) { 2 }

      it 'returns the discounted price' do
        expect(discounted).to eq(8.5)
      end
    end

    context 'discount type is not promo price' do
      let(:item_code) { '002' }
      let(:price) { 30 }
      let(:quantity) { 2 }

      it 'returns the original price' do
        expect(discounted).to eq(price)
      end
    end
  end
end
