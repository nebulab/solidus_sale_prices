require 'spec_helper'

RSpec.feature 'Admin sale prices' do
  stub_authorization!

  let(:country) { create(:country, iso: 'IT') }
  let(:price) { create(:price, country: country, currency: 'EUR') }
  let(:variant) { create(:variant, prices: [price]) }
  let!(:sale_price) { create(:sale_price, price: price) }

  context 'when listed' do
    let!(:expired_sale_price) do
      create(:sale_price, price: variant.prices.first, end_at: 1.day.ago)
    end
    let!(:scheduled_sale_price) do
      create(:sale_price, price: variant.prices.first, start_at: 1.day.from_now)
    end

    scenario 'are shown along with variant prices' do
      visit spree.admin_product_sale_prices_path(product_id: variant.product.slug)

      within('[data-hook="current_prices"] [data-hook="prices_row"]:first') do
        expect(page).to have_content(variant.product.master.descriptive_name)
        expect(page).to have_content(variant.product.master.price)
      end

      within('[data-hook="current_prices"] [data-hook="prices_row"]:last') do
        expect(page).to have_content(variant.descriptive_name)
        expect(page).to have_content(variant.price)
      end

      within all('[data-hook="sale_prices"] [data-hook="prices_row"]').first do
        expect(page).to have_content(sale_price.variant.descriptive_name)
        expect(page).to have_content(sale_price.display_price)
        expect(page).to have_content(I18n.t('spree.sale_price_active'))
      end

      within all('[data-hook="sale_prices"] [data-hook="prices_row"]')[1] do
        expect(page).to have_content(sale_price.variant.descriptive_name)
        expect(page).to have_content(sale_price.display_price)
        expect(page).to have_content(I18n.t('spree.sale_price_expired'))
      end

      within all('[data-hook="sale_prices"] [data-hook="prices_row"]').last do
        expect(page).to have_content(sale_price.variant.descriptive_name)
        expect(page).to have_content(sale_price.display_price)
        expect(page).to have_content(I18n.t('spree.sale_price_scheduled'))
      end
    end
  end

  context 'when adding new ones' do
    around { |example| Timecop.freeze { example.run } }

    let(:start_at) { 2.days.ago }
    let(:end_at) { 2.days.from_now }

    scenario 'cannot be added when no price is selected' do
      visit spree.new_admin_product_sale_price_path(product_id: variant.product.slug)

      expect(page).to have_selector('.flash.error', text: I18n.t('spree.put_on_sale_requires_prices'))
    end

    scenario 'can be added', js: true do
      visit spree.admin_product_sale_prices_path(product_id: variant.product.slug)

      find("[data-hook='current_prices'] #spree_price_#{variant.prices.first.id}").click
      click_button('New Sale Price')

      find('#sale_price_start_at').click
      find(".flatpickr-day[aria-label='#{start_at.strftime('%B %-d, %Y')}']").click
      find('.flatpickr-hour').set(20)
      find('.flatpickr-minute').set(22)

      find('#sale_price_end_at').click
      find(".flatpickr-day[aria-label='#{end_at.strftime('%B %-d, %Y')}']").click
      find('.flatpickr-hour').set(10)
      find('.flatpickr-minute').set(32)

      fill_in('sale_price_value', with: 32.33)
      click_button('Create')
      within all('[data-hook="sale_prices"] [data-hook="prices_row"]').last do
        expect(page).to have_content(variant.descriptive_name)
        expect(page).to have_content(32.33)
        expect(page).to have_content(country.name)
        expect(page).to have_content(variant.prices.first.currency)
        expect(page).to have_content(start_at.strftime('%B %d, %Y'))
        expect(page).to have_content(end_at.strftime('%B %d, %Y'))
      end
    end
  end

  scenario 'can be destroyed', js: true do
    visit spree.admin_product_sale_prices_path(product_id: variant.product.slug)

    within('[data-hook="sale_prices"]') do
      expect(page).to have_selector('[data-hook="prices_row"]', count: 1)
      accept_alert { find('.delete-resource').click }
      expect(page).to have_selector('[data-hook="prices_row"]', count: 0)
    end
  end
end
