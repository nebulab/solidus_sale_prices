require 'spec_helper'

describe Spree::SalePrice do
  describe '#start' do
    let(:sale_price) { build(:sale_price) }

    context 'when it starts without an end time' do
      before { sale_price.start }

      it 'enables the sale price' do
        expect(sale_price).to be_enabled
      end

      it 'unsets the end time' do
        expect(sale_price.end_at).to be_nil
      end
    end

    context 'when it starts with an end time' do
      before { sale_price.start(1.day.from_now) }

      it 'enables the sale price' do
        expect(sale_price).to be_enabled
      end

      it 'sets the end time' do
        expect(sale_price.end_at).to be_within(1.second).of(1.day.from_now)
      end
    end
  end

  describe '#stop' do
    let(:sale_price) { build(:active_sale_price) }

    before { sale_price.stop }

    it 'disables the sale price' do
      expect(sale_price).not_to be_enabled
    end

    it 'sets the end time' do
      expect(sale_price.end_at).to be_within(2.second).of(Time.now)
    end
  end

  describe '#display_price' do
    let(:sale_price) { create(:active_sale_price) }
    subject(:display_price) { sale_price.display_price }

    it 'is expected to be an instance of Spree::Money' do
      expect(display_price).to be_a Spree::Money
    end

    it 'is expected to be similar to the calculated price' do
      expect(display_price.money.amount.to_f).to be_within(0.1).of(sale_price.calculated_price.to_f)
    end

    it 'is expected to have the same currency of sale price' do
      expect(display_price.money.currency).to eq(sale_price.currency)
    end
  end

  describe '#price_with_deleted' do
    context 'when the associated price is destroyed' do
      let(:sale_price) { create(:sale_price) }
      let(:price) { sale_price.price }

      before do
        price.discard
        sale_price.reload
      end

      it 'still can find the price via price_with_deleted association' do
        expect(sale_price.price).to be_nil
        expect(sale_price.price_with_deleted).to eql price
      end
    end
  end

  describe '#variant association' do
    context 'when the price has been soft-deleted' do
      before do
        sale = create :sale_price
        sale.price.discard
      end

      it 'preloads the variant via SQL also for soft-deleted records' do
        records = Spree::SalePrice.with_discarded.includes(:variant)
        expect(records.first.variant).to be_present
      end
    end
  end

  context 'touching associated product when destroyed' do
    subject { -> { sale_price.reload.discard } }
    let!(:product) { sale_price.product }
    let(:sale_price) { Timecop.travel(1.day.ago) { create(:sale_price) } }

    it { is_expected.to change { product.reload.updated_at } }

    context 'when product association has been destroyed' do
      before { sale_price.variant.update_columns(product_id: nil) }

      it 'does not touch product' do
        expect(subject).not_to change { product.reload.updated_at }
      end
    end

    context 'when associated variant has been destroyed' do
      before { sale_price.variant.discard }

      it 'does not touch product' do
        expect(subject).not_to change { product.reload.updated_at }
      end
    end

    context 'when associated price has been destroyed' do
      before { sale_price.price.discard }

      it 'does not touch product' do
        expect(subject).not_to change { product.reload.updated_at }
      end
    end
  end

  describe '.ordered' do
    subject { described_class.ordered }

    let!(:forever) { create(:sale_price) }
    let!(:future) { create(:sale_price, start_at: 10.days.from_now) }
    let!(:past) { create(:sale_price, start_at: 10.days.ago) }
    let!(:present) { create(:active_sale_price) }

    it { is_expected.to match [forever, past, present, future] }
  end

  describe '.for_product' do
    subject { described_class.for_product(product) }

    before { product.put_on_sale(10.95) }

    context 'without variants' do
      let(:product) { create(:product) }

      it { is_expected.to match product.master.sale_prices }
    end

    context 'with variants' do
      let(:variant) { create(:variant) }
      let(:product) { variant.product }

      it { is_expected.to match_array(variant.sale_prices + product.master.sale_prices) }
    end
  end
end
