require 'spec_helper'

describe Spree::Price do
  let(:price) { create(:price, amount: price_amount) }
  let(:price_amount) { 19.99 }

  describe '#new_sale' do
    subject { price.new_sale(sale_price_value) }

    let(:sale_price_value) { 15.99 }

    it 'builds a new sale' do
      is_expected.to have_attributes({
        value: BigDecimal(sale_price_value, 4),
        start_at: be_within(1.second).of(Time.now),
        end_at: nil,
        enabled: true,
        calculator: an_instance_of(Spree::Calculator::FixedAmountSalePriceCalculator)
      })
    end
  end

  describe '#put_on_sale' do
    subject(:put_on_sale) { price.put_on_sale sale_price_value, options }

    context 'when the sale price calculator is not passed as argument' do
      let(:sale_price_value) { 15.95 }
      let(:options) { {} }

      it 'puts the price on sale' do
        expect { put_on_sale }.to change { price.reload.on_sale? }.from(false).to(true)
      end

      it "updates the price's price" do
        expect { put_on_sale }.to change { price.reload.price }.from(price_amount).to(BigDecimal(sale_price_value, 4))
      end

      it "sets original_price" do
        put_on_sale

        expect(price.original_price).to eq price_amount
      end
    end

    context 'when the sale price calculator passed as argument is percent off' do
      let(:sale_price_value) { 0.2 }
      let(:options) { { calculator_type: Spree::Calculator::PercentOffSalePriceCalculator.new } }

      it 'puts the price on sale' do
        expect { put_on_sale }.to change { price.reload.on_sale? }.from(false).to(true)
      end

      it "updates the price's price" do
        expect { put_on_sale }.to change { price.reload.price }.from(price_amount).to(be_within(0.01).of(15.99))
      end

      it "sets original_price" do
        put_on_sale

        expect(price.original_price).to eq price_amount
      end
    end
  end

  describe '#discount_percent' do
    subject { price.discount_percent.to_f }

    context 'when there is no original price' do
      before { price.amount = BigDecimal(0) }

      it { is_expected.to be_zero }
    end

    context 'when it is not on sale' do
      it { is_expected.to be_zero }
    end

    context 'when it is on sale' do
      before { price.put_on_sale(15.00) }

      it 'returns correct percentage value' do
        is_expected.to be_within(0.1).of(25)
      end
    end
  end

  describe '#destroy' do
    context 'when there are sale prices associated to the price' do
      before { price.put_on_sale 10 }

      it 'destroys all sale prices when it is destroyed' do
        expect { price.discard }
          .to change { Spree::SalePrice.all.size }
          .from(1).to(0)
      end
    end
  end

  describe 'on_sale?' do
    subject { price.on_sale? }

    context 'when there are no active sales' do
      it { is_expected.to be_falsey }
    end

    context 'when there is one active sale but its calculated price is equal to the original price' do
      before { price.put_on_sale price_amount }

      it { is_expected.to be_falsey }
    end

    context 'when there is one active sale and its calculated price is less than the original price' \
            'but its value is greater than the original price' do
      let(:price_amount) { 0.09 }

      before { price.put_on_sale 0.1, calculator_type: Spree::Calculator::PercentOffSalePriceCalculator.new }

      it { is_expected.to be_truthy }
    end

    context 'when there is one active sale and its calculated price is less than the original price' do
      before { price.put_on_sale price_amount - 0.01 }

      it { is_expected.to be_truthy }
    end
  end

  describe '#recalculate_sale_prices' do
    before do
      price.put_on_sale 0.1, calculator_type: Spree::Calculator::PercentOffSalePriceCalculator.new
      price.put_on_sale 0.2, calculator_type: Spree::Calculator::PercentOffSalePriceCalculator.new
    end

    context 'when the price amount changes' do
      before { price.update! amount: 100 }

      it 'updates calculated sale prices' do
        expect(price.sale_prices.pluck(:calculated_price)).to contain_exactly 90, 80
      end
    end
  end
end
