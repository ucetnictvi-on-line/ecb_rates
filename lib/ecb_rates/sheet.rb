require 'date'

module EcbRates
  # This class represents a daily EUR exchange rate sheet
  # according to the European Central Bank (ECB) website.
  # It has two constructors: +Sheet.today+ for the current
  # exchange rate sheet, and +Sheet.day+ for historical
  # exchange rate sheets for the# past 90 days. The class
  # has +#currency+ instance method, allowing syntax:
  #
  #   EcbRates::Sheet.today.currency 'USD'
  #
  # In addition, the class defines an instance method for
  # each supported currency, such as:
  #
  #   EcbRates::Sheet.today.USD
  #   EcbRates::Sheet.today.JPY
  # 
  class Sheet 
    class << self
      private :new

      # Constructs today's EUR exchange rate sheet from
      # the information provided by the European Central
      # Bank (ECB) website. The method gives a warning
      # message if the date on the host computer differs
      # from the date on the ECB website.
      # 
      def today
        begin
          doc = open TODAY_RATES_URL
        rescue SocketError
          raise WebsiteUnavailable, "Can't connect to ECB!"
        rescue OpenURI::HTTPError
          raise ExchangeRateSheetUnavailable, "Today's " \
            "exchange rate sheet not found on ECB " \
            "website! Searched URL: #{TODAY_RATES_URL}"
        end

        xml = Nokogiri.XML(doc)
        ecb_date = xml.at_css(ANY_TIME_MARKUP).to_h["time"]
        date = Date.parse(ecb_date)
        
        unless date = Date.today
          warn "Date on your computer (#{Date.today}) is " \
               "not the same as the date according to ECB " \
               "(#{date})!"
        end

        new(xml, date)
      end

      # Constructs EUR exchange rate sheet for a certain day
      # within past 90 days. Expects one argument, the date.
      # The date can be in a string format, such as
      # '2015-07-31', or it can be a +Date+ object.
      # 
      def day(date)
        date = normalize_date(date)

        begin
          doc = open HISTORY_RATES_URL
        rescue SocketError
          raise WebsiteUnavailable, "Can't connect to ECB!"
        rescue OpenURI::HTTPError
          raise ExchangeRateSheetUnavailable, "Historical " \
                "exchange rates not found on ECB website! " \
                "Searched URL: #{HISTORY_RATES_URL}"
        end

        # FIXME: Make sure that the required historical date
        # is on the 90 day history sheet provided by ECB,
        # raise error if not.

        xml = Nokogiri.XML(doc)
        new(xml, date)
      end
    
      private

      def normalize_date(date)
        case date
        when Date, DateTime
          date.strftime('%Y-%m-%d')
        else
          normalize_date(Date.parse(date))
        end
      end
    end

    # :nodoc:
    def initialize(source, date)
      @source = source
      @date = normalize_date(date)
    end

    # Returns the date for which this sheet is valid. The
    # returned date is an object of +Date+ class.
    # 
    def date
      Date.parse(@date)
    end

    # Returns the exchange rate from this sheet for a given
    # currency. Requires one argument, the currency
    # abbreviation.
    # 
    def currency(curr)
      @source.
        at_css(currency_path(curr)).
        to_h["rate"]
    end

    # Allows asking about the currency exchange rates simply
    # by using methods such as +#USD+ or +#JPY. Examples:
    #
    #   EcbRates::Sheet.today.USD
    #   EcbRates::Sheet.today.JPY
    #   
    def method_missing(curr, *args, &block)
      rate = currency(curr)
      return super if rate.nil?
      return rate if args.empty?
      fail ArgumentError,
           "Currency methods do not take arguments!"
    end

    # :nodoc:
    def respond_to_missing?(curr, include_private = false)
      currency(curr).nil? ? super : true
    end

    private

    # :nodoc:
    def normalize_date
      self.class.normalize_date
    end

    # :nodoc:
    def currency_path(curr)
      (TIME_MARKUP + '//' + CURRENCY_MARKUP) % [@date, curr]
    end
  end # class Sheet
end # module EcbRates
