require 'spec_helper'

RSpec.feature 'Admin sale prices' do
  stub_authorization!

  let(:product) { create(:product) }
  let(:small) do
    create(:variant, product: product,
                     option_values: [create(:option_value, presentation: 'S')])
  end
  let(:medium) do
    create(:variant, product: product,
                     option_values: [create(:option_value, presentation: 'M')])
  end
  let(:large) do
    create(:variant, product: product,
                     option_values: [create(:option_value, presentation: 'L')])
  end

  context 'when listing sale prices' do
    before { product.put_on_sale(20.25, start_at: 1.hour.from_now) }

    scenario 'with the master variant the product sale is shown' do
      visit spree.admin_product_sale_prices_path(product_id: product.slug)

      expect(page).to have_selector('[data-hook="products_row"]', count: 1)
      expect(page).not_to have_selector('.variant_sales_picker')

      within('[data-hook="products_row"]:first') do
        expect(page).to have_content(product.sku)
      end
    end

    context 'with multiple variants' do
      before do
        small.put_on_sale(10.95, start_at: 5.days.from_now)
        medium.put_on_sale(11.95, start_at: 10.days.from_now)
        large.put_on_sale(32.21, start_at: 2.hours.from_now)
      end

      scenario 'a list of variant sale prices is shown and sorted by start_at' do
        visit spree.admin_product_sale_prices_path(product_id: product.slug)

        expect(page).to have_selector('[data-hook="products_row"]', count: 4)

        within('[data-hook="products_row"]:first') do
          expect(page).to have_content(product.sku)
        end

        within('[data-hook="products_row"]:nth-child(2)') do
          expect(page).to have_content(large.sku)
        end

        within('[data-hook="products_row"]:nth-child(3)') do
          expect(page).to have_content(small.sku)
        end

        within('[data-hook="products_row"]:last') do
          expect(page).to have_content(medium.sku)
        end
      end
    end
  end

  context 'when adding sale prices', js: true do
    scenario 'a new sale price is added to the list' do
      visit spree.admin_product_sale_prices_path(product_id: product.slug)

      fill_in('Sale Price', with: 32.33)
      fill_in('Sale Start Date', with: '2016/12/11 16:12')
      fill_in('Sale End Date', with: '2016/12/17 05:35 pm')
      click_button('Add Sale Price')

      within('[data-hook="products_row"]') do
        expect(page).to have_content(product.sku)
        expect(page).to have_content(32.33)

        within('.start-date') { expect(page).to have_content('December 11, 2016 4:12 PM') }
        within('.end-date') { expect(page).to have_content('December 17, 2016 5:35 PM') }
      end
    end

    context 'with multiple variants' do
      before { small; medium; large }

      scenario 'a new sale price is added to the list' do
        visit spree.admin_product_sale_prices_path(product_id: product.slug)

        fill_in('Sale Price', with: 32.33)
        fill_in('Sale Start Date', with: '2016/12/11 16:12')
        fill_in('Sale End Date', with: '2016/12/17 05:35 pm')
        click_button('Add Sale Price')

        expect(page).to have_selector('[data-hook="products_row"]', count: 4)
      end

      if Spree.solidus_gem_version >= Gem::Version.new('2.5.0')
        scenario 'only certain variants are added if selected' do
          visit spree.admin_product_sale_prices_path(product_id: product.slug)

          find('#sale_price_start_at').click
          find(".flatpickr-day[aria-label='#{2.day.ago.strftime('%B %e, %Y')}']").click

          find('#sale_price_end_at').click
          find(".flatpickr-day[aria-label='#{2.day.from_now.strftime('%B %e, %Y')}']").click

          fill_in('Sale Price', with: 32.33)

          find('.select2-choices').click
          find('.select2-result-label', exact_text: product.master.sku_and_options_text).click
          find('.select2-choices').click
          find('.select2-result-label', exact_text: small.sku_and_options_text).click
          find('.select2-choices').click
          find('.select2-result-label', exact_text: medium.sku_and_options_text).click

          click_button('Add Sale Price')
          expect(page).to have_selector('[data-hook="products_row"]', count: 3)
        end
      else
        scenario 'only certain variants are added if selected' do
          visit spree.admin_product_sale_prices_path(product_id: product.slug)

          fill_in('Sale Price', with: 32.33)
          fill_in('Sale Start Date', with: '2016/12/11 16:12')
          fill_in('Sale End Date', with: '2016/12/17 05:35 pm')

          find('.select2-choices').click
          find('.select2-result-label', exact_text: product.master.sku_and_options_text).click
          find('.select2-choices').click
          find('.select2-result-label', exact_text: small.sku_and_options_text).click
          find('.select2-choices').click
          find('.select2-result-label', exact_text: medium.sku_and_options_text).click

          click_button('Add Sale Price')
          expect(page).to have_selector('[data-hook="products_row"]', count: 3)
        end
      end

      if Spree.solidus_gem_version >= Gem::Version.new('2.5.0')
        scenario 'only non-master variants are added if selected' do
          visit spree.admin_product_sale_prices_path(product_id: product.slug)

          find('#sale_price_start_at').click
          find(".flatpickr-day[aria-label='#{2.day.ago.strftime('%B %e, %Y')}']").click

          find('#sale_price_end_at').click
          find(".flatpickr-day[aria-label='#{2.day.from_now.strftime('%B %e, %Y')}']").click

          fill_in('Sale Price', with: 32.33)

          find('.select2-choices').click
          find('.select2-result-label', exact_text: small.sku_and_options_text).click
          find('.select2-choices').click
          find('.select2-result-label', exact_text: medium.sku_and_options_text).click

          click_button('Add Sale Price')
          expect(page).to have_selector('[data-hook="products_row"]', count: 2)
        end
      else
        scenario 'only non-master variants are added if selected' do
          visit spree.admin_product_sale_prices_path(product_id: product.slug)

          fill_in('Sale Price', with: 32.33)
          fill_in('Sale Start Date', with: '2016/12/11 16:12')
          fill_in('Sale End Date', with: '2016/12/17 05:35 pm')

          find('.select2-choices').click
          find('.select2-result-label', exact_text: small.sku_and_options_text).click
          find('.select2-choices').click
          find('.select2-result-label', exact_text: medium.sku_and_options_text).click

          click_button('Add Sale Price')
          expect(page).to have_selector('[data-hook="products_row"]', count: 2)
        end
      end
    end
  end

  context 'when editing sale prices', js: true do
    around { |example| Timecop.freeze { example.run } }

    before do
      small.put_on_sale(54.95, start_at: 1.day.ago, end_at: 1.day.from_now)
      medium
    end

    if Spree.solidus_gem_version >= Gem::Version.new('2.5.0')
      def match_date(date)
        Regexp.new(Regexp.escape(I18n.l(date, format: :datetimepicker)), 'i')
      end

      scenario 'updates the sale price inplace' do
        visit spree.admin_product_sale_prices_path(product_id: product.slug)

        find('[data-action="edit"]').click
        expect(page).to have_selector('[data-hook="products_row"]', count: 1)

        expect(find_field('Sale Price', with: '54.95')).to be_visible

        expect(find_field('Sale Start Date', with: match_date(1.day.ago))).to be_visible
        expect(find_field('Sale End Date', with: match_date(1.day.from_now))).to be_visible

        find('#sale_price_end_at').click
        find(".flatpickr-day[aria-label='#{2.day.from_now.strftime('%B %e, %Y')}']").click

        find('#sale_price_start_at').click
        find(".flatpickr-day[aria-label='#{2.day.ago.strftime('%B %e, %Y')}']").click

        fill_in('Sale Price', with: 32.33)

        click_button('Update Sale Price')

        expect(page).to have_selector('[data-hook="products_row"]', count: 1)
        within('[data-hook="products_row"]') do
          expect(page).to have_content(small.sku)
          expect(page).to have_content('32.33')

          within('.start-date') { expect(page).to have_content(pretty_time(2.days.ago)) }
          within('.end-date') { expect(page).to have_content(pretty_time(2.days.from_now)) }
        end
      end
    else
      scenario 'updates the sale price inplace' do
        visit spree.admin_product_sale_prices_path(product_id: product.slug)

        find('[data-action="edit"]').click
        expect(page).to have_selector('[data-hook="products_row"]', count: 1)

        expect(find_field('Sale Price', with: '54.95')).to be_visible
        expect(find_field('Sale Start Date', with: I18n.l(1.day.ago, format: :datetimepicker))).to be_visible
        expect(find_field('Sale End Date', with: I18n.l(1.day.from_now, format: :datetimepicker))).to be_visible

        fill_in('Sale Price', with: 32.33)
        fill_in('Sale Start Date', with: I18n.l(2.days.ago, format: :datetimepicker))
        fill_in('Sale End Date', with: I18n.l(2.days.from_now, format: :datetimepicker))
        click_button('Update Sale Price')

        expect(page).to have_selector('[data-hook="products_row"]', count: 1)
        within('[data-hook="products_row"]') do
          expect(page).to have_content(small.sku)
          expect(page).to have_content('32.33')

          within('.start-date') { expect(page).to have_content(pretty_time(2.days.ago)) }
          within('.end-date') { expect(page).to have_content(pretty_time(2.days.from_now)) }
        end
      end
    end
  end
end
