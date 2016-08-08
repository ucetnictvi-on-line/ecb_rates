module EcbRates
  class Sheet 
    class << self
      def today
        begin
          doc = open(TODAY_RATES_URL)
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

      def day( date )
        date = normalize_date(date)

        begin
          doc = open(HISTORY_RATES_URL)
        rescue SocketError
          raise WebsiteUnavailable, "Can't connect to ECB!"
        rescue OpenURI::HTTPError
          raise ExchangeRateSheetUnavailable, "Historical " \
                "exchange rates not found on ECB website! " \
                "Searched URL: #{HISTORY_RATES_URL}"
        end

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

    def initialize(source, date)
      @source = source
      @date = normalize_date(date)
    end

    def date
      Date.parse(@date)
    end

    def currency(curr)
      @source.
        at_css(currency_path(curr)).
        to_h["rate"]
    end

    def method_missing(curr, *args, &block)
      rate = currency(curr)
      return super if rate.nil?
      return rate if args.empty?
      fail ArgumentError,
           "Currency methods do not take arguments!"
    end

    def respond_to_missing?(curr, include_private = false)
      currency(curr).nil? ? super : true
    end

    def normalize_date
      self.class.normalize_date
    end

    private

    def currency_path(curr)
      (TIME_MARKUP + '//' + CURRENCY_MARKUP) % [@date, curr]
    end
  end # class Sheet
end # module EcbRates
