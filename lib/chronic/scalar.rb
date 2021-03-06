module Chronic
  class Scalar < Tag
    DAY_PORTIONS = %w( am pm morning afternoon evening night )

    # Scan an Array of Token objects and apply any necessary Scalar
    # tags to each token.
    #
    # tokens - An Array of tokens to scan.
    # options - The Hash of options specified in Chronic::parse.
    #
    # Returns an Array of tokens.
    def self.scan(tokens, options)
      tokens.each_index do |i|
        if t = scan_for_scalars(tokens[i], tokens[i + 1]) then tokens[i].tag(t) end
        if t = scan_for_days(tokens[i], tokens[i + 1]) then tokens[i].tag(t) end
        if t = scan_for_months(tokens[i], tokens[i + 1]) then tokens[i].tag(t) end
        if t = scan_for_years(tokens[i], tokens[i + 1], options) then tokens[i].tag(t) end
      end
    end

    # token - The Token object we want to scan.
    # post_token - The next Token object.
    #
    # Returns a new Scalar object.
    def self.scan_for_scalars(token, post_token)
      if token.word =~ /^\d*$/
        unless post_token && DAY_PORTIONS.include?(post_token.word)
          return Scalar.new(token.word.to_i)
        end
      end
    end

    # token - The Token object we want to scan.
    # post_token - The next Token object.
    #
    # Returns a new Scalar object.
    def self.scan_for_days(token, post_token)
      if token.word =~ /^\d\d?$/
        toi = token.word.to_i
        unless toi > 31 || toi < 1 || (post_token && DAY_PORTIONS.include?(post_token.word))
          return ScalarDay.new(toi)
        end
      end
    end

    # token - The Token object we want to scan.
    # post_token - The next Token object.
    #
    # Returns a new Scalar object.
    def self.scan_for_months(token, post_token)
      if token.word =~ /^\d\d?$/
        toi = token.word.to_i
        unless toi > 12 || toi < 1 || (post_token && DAY_PORTIONS.include?(post_token.word))
          return ScalarMonth.new(toi)
        end
      end
    end

    # token - The Token object we want to scan.
    # post_token - The next Token object.
    # options - The Hash of options specified in Chronic::parse.
    #
    # Returns a new Scalar object.
    def self.scan_for_years(token, post_token, options)
      if token.word =~ /^([1-9]\d)?\d\d?$/
        unless post_token && DAY_PORTIONS.include?(post_token.word)
          year = make_year(token.word.to_i, options[:ambiguous_year_future_bias])
          return ScalarYear.new(year.to_i)
        end
      end
    end

    # Build a year from a 2 digit suffix.
    #
    # year - The two digit Integer year to build from.
    # bias - The Integer amount of future years to bias.
    #
    # Examples:
    #
    #   make_year(96, 50) #=> 1996
    #   make_year(79, 20) #=> 2079
    #   make_year(00, 50) #=> 2000
    #
    # Returns The Integer 4 digit year.
    def self.make_year(year, bias)
      return year if year.to_s.size > 2
      start_year = Chronic.time_class.now.year - bias
      century = (start_year / 100) * 100
      full_year = century + year
      full_year += 100 if full_year < start_year
      full_year
    end

    def to_s
      'scalar'
    end
  end

  class ScalarDay < Scalar #:nodoc:
    def to_s
      super << '-day-' << @type.to_s
    end
  end

  class ScalarMonth < Scalar #:nodoc:
    def to_s
      super << '-month-' << @type.to_s
    end
  end

  class ScalarYear < Scalar #:nodoc:
    def to_s
      super << '-year-' << @type.to_s
    end
  end
end