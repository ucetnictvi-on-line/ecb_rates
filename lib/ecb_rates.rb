require 'nokogiri'
require_relative 'ecb_rates/version'
require_relative 'ecb_rates/sheet'

# Gem <tt>'ecb_rates'</tt> provides access to the currency
# exchange rate sheets from European Central Bank (ECB).
# Exchange rates are available for today, or for any of the
# past 90 days. Example:
# 
#   EcbRates.today.currency('USD')
#   EcbRates.day('2016-08-31').currency(:JPY)
# 
# Or shorter:
# 
#   EcbRates.today.USD
#   EcbRates.day('2016-08-31').JPY
# 
module EcbRates
  # URLs of European Central Bank resources.
  BASE_URL = 'http://www.ecb.europa.eu/stats/eurofxref/'
  TODAY_RATES_URL = BASE_URL + 'eurofxref-daily.xml'
  HISTORY_RATES_URL = BASE_URL + 'eurofxref-hist-90d.xml'

  # XML markup tags.
  TIME_MARKUP = 'Cube[time="%s"]'
  ANY_TIME_MARKUP = 'Cube[time]'
  CURRENCY_MARKUP = 'Cube[currency="%s"]'

  VALID_CURRENCIES = [
    :USD, :JPY, :BGN, :CZK, :DKK, :GBP, :HUF, :PLN, :RON, :SEK, :CHF, :NOK,
    :HRK, :RUB, :TRY, :AUD, :BRL, :CAD, :CNY, :HKD, :IDR, :ILS, :INR, :KRW,
    :MXN, :MRY, :NZD, :PHP, :SGB, :THB, :ZAR
  ]

  DateTooOld = Class.new StandardError
  CurrencyMissing = Class.new StandardError
  CurrencyNotSupported = Class.new StandardError
  WebsiteUnavailable = Class.new StandardError
  ExchangeRateSheetUnavailable = Class.new StandardError

  class << self
    delegate :day, :today, to: Sheet

    def exchange_rate(currency, date=Date.today)
      # TODO: Suggest deprecating this method.
      Sheet.day(date).currency(currency)
    end
  end
end
