require 'nokogiri'
require_relative 'ecb_rates/version'
require_relative 'ecb_rates/application'
require_relative 'ecb_rates/exchange_rates'

module EcbRates
  TODAY_RATES_URL =
    'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
  HISTORY_RATES_URL =
    'http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml'
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
    def exchange_rates_today
  end
  def self.exchange_rate currency, date=Date.today
    app = Application.new
    app.exchange_rate(currency, date)
  end
end
