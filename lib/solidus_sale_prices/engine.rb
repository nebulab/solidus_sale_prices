module SolidusSalePrices
  class Engine < Rails::Engine
    engine_name 'solidus_sale_prices'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(__dir__, '..', '..', 'app', 'prependers', '**', '*.rb')) do |c|
        require(c)
      end

      Prependers.load_paths(*Dir.glob(File.expand_path(File.join('..', '..', 'app', 'prependers', '*'), __dir__)), namespace: SolidusSalePrices)
    end

    config.to_prepare &method(:activate).to_proc
  end
end
