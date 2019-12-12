# frozen_string_literal: true

require 'spec_helper'
require 'ostruct'
require_relative '../../lib/checkout'

describe Checkout do
  let(:checkout) { Checkout.new }
  let(:rules) do
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
  let(:item1) { OpenStruct.new(code: '001', name: 'T-shirt', price: 9.25) }
  let(:item2) { OpenStruct.new(code: '002', name: 'Pants', price: 45.00) }
  let(:item3) { OpenStruct.new(code: '003', name: 'Socks', price: 19.95) }

  describe '#scan' do
    context 'item is scanned for the first time' do
      before do
        checkout.scan(item1)
      end

      it 'adds item to the checkout' do
        checkout_item = checkout.find_by_code(item1.code)
        expect(checkout_item[:data]).to eq item1
        expect(checkout_item[:quantity]).to eq 1
      end

      it 'increases the items count' do
        items_count = checkout.items_count
        expect(items_count).to eq 1
      end
    end

    context 'items are scanned for multiple times' do
      before do
        [item1, item2, item1].each { |item| checkout.scan(item) }
      end

      it 'adds items to the checkout' do
        checkout_item = checkout.find_by_code(item1.code)
        expect(checkout_item[:data]).to eq item1
        expect(checkout_item[:quantity]).to eq 2
      end

      it 'increases the items count' do
        items_count = checkout.items_count
        expect(items_count).to eq 3
      end
    end
  end

  describe '#find_by_code' do
    context 'item is in the checkout' do
      before do
        checkout.scan(item1)
      end

      it 'returns the found item' do
        checkout_item = checkout.find_by_code(item1.code)
        expect(checkout_item[:data]).to eq item1
        expect(checkout_item[:quantity]).to eq 1
      end
    end

    context 'item is not in the checkout' do
      it 'returns nil' do
        checkout_item = checkout.find_by_code(item2.code)
        expect(checkout_item).to be_nil
      end
    end
  end

  describe '#total' do
    before do
      [item1, item2, item2, item1, item3].each { |item| checkout.scan(item) }
    end

    context 'checkout without promotion rules' do
      let(:checkout) { Checkout.new }

      it 'returns original total' do
        # 9.25 * 2 + 45.00 * 2 + 19.95
        expect(checkout.total).to eq(128.45)
      end
    end

    context 'checkout with promotion rules' do
      let(:checkout) { Checkout.new(rules) }

      it 'returns discounted total' do
        # (8.5 * 2 + 45.00 * 2 + 19.95) * 0.9
        expect(checkout.total).to eq(114.26)
      end
    end
  end
end
