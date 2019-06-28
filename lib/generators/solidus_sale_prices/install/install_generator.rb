module SolidusSalePrices
  module Generators
    class InstallGenerator < Rails::Generators::Base
      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require #{solidus_sale_price_js_file}\n"
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/solidus_sale_prices\n"
        append_file 'vendor/assets/javascripts/spree/frontend/all.js', "//= require spree/frontend/solidus_sale_prices\n"
      end

      def add_stylesheets
        inject_into_file 'vendor/assets/stylesheets/spree/frontend/all.css', " *= require spree/frontend/solidus_sale_prices\n", before: /\*\//, verbose: true
        inject_into_file 'vendor/assets/stylesheets/spree/backend/all.css', " *= require spree/backend/solidus_sale_prices\n", before: /\*\//, verbose: true
      end

      def add_migrations
        run 'bundle exec rake railties:install:migrations FROM=solidus_sale_prices'
      end

      def run_migrations
        run 'bundle exec rake db:migrate'
      end

      private

      def solidus_sale_price_js_file
        return 'spree/backend/flatpickr' if Spree.solidus_gem_version >= Gem::Version.new('2.5.0')

        'spree/backend/jquery-datetimepicker'
      end
    end
  end
end
