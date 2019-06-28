Spree::BaseHelper.class_eval do
  def display_original_price(product_or_variant)
    product_or_variant.original_price_in(_current_currency).display_price.to_html
  end

  def display_discount_percent(product_or_variant, append_text = 'Off')
    discount = product_or_variant.discount_percent_in _current_currency

    return "#{number_to_percentage(discount, precision: 0).to_html} #{append_text}" if discount > 0

    ''
  end

  # Check if a sale is the current sale for a product, returns true or false
  def active_for_sale_price product, sale_price
    product.current_sale_in(_current_currency) == sale_price
  end

  def supported_currencies_for_sale_price
    try(:supported_currencies) || [ _current_currency ]
  end

  def gte_solidus_2_4?
    gte_solidus?('2.4.0')
  end

  def gte_solidus_2_5?
    gte_solidus?('2.5.0')
  end

  def gte_solidus?(version)
    SolidusSupport.solidus_gem_version >= Gem::Version.new(version)
  end

  private

  def _current_currency
    try(:current_currency) || Spree::Config[:currency] || 'USD'
  end
end
