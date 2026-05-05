# frozen_string_literal: true

require "i18n"

module OrdinalizeFull
  I18n.load_path += Dir[File.join(__dir__, "ordinalize_full/locales/*.yml")]

  GENDERS = %i[masculine feminine].freeze
  PLURALITIES = %i[singular plural].freeze

  # Ordered longest-first so two-letter endings match before their one-letter prefixes.
  ES_SHORT_SUFFIXES = {
    "er" => ".ᵉʳ",
    "os" => ".ᵒˢ",
    "as" => ".ᵃˢ",
    "o" => ".ᵒ",
    "a" => ".ᵃ"
  }.freeze

  def ordinalize(in_full: false, gender: :masculine, plurality: :singular)
    OrdinalizeFull.validate!(gender, plurality)
    if in_full
      ordinalize_in_full(gender: gender, plurality: plurality)
    else
      ordinalize_in_short(gender: gender, plurality: plurality)
    end
  end

  def ordinalize_in_full(gender: :masculine, plurality: :singular)
    OrdinalizeFull.validate!(gender, plurality)
    ordinalize_via_namespace("ordinalize_spatial", gender: gender, plurality: plurality)
  end

  def ordinalize_in_precedence(gender: :masculine, plurality: :singular)
    OrdinalizeFull.validate!(gender, plurality)
    ordinalize_via_namespace("ordinalize_precedence", gender: gender, plurality: plurality)
  end

  alias_method :ordinalize_full, :ordinalize_in_full
  alias_method :ordinalize_precedence, :ordinalize_in_precedence

  def self.validate!(gender, plurality)
    raise ArgumentError, "Unknown gender #{gender.inspect} (expected one of #{GENDERS.inspect})" unless GENDERS.include?(gender)
    raise ArgumentError, "Unknown plurality #{plurality.inspect} (expected one of #{PLURALITIES.inspect})" unless PLURALITIES.include?(plurality)
  end

private

  def ordinalize_via_namespace(namespace, gender:, plurality:)
    case I18n.locale
    when :fr, :de
      value = I18n.t("#{namespace}.n_#{self}_#{gender}", default: "")
      value = I18n.t("#{namespace}.n_#{self}", raise: true) if value.empty?
      value
    when :es
      value = I18n.t("#{namespace}.n_#{self}", default: "")

      if value.empty?
        value = [
          I18n.t("#{namespace}.n_#{(self / 10) * 10}", raise: true),
          I18n.t("#{namespace}.n_#{self % 10}", raise: true)
        ].join(" ")
      end

      value = value.split.map { |part| "#{part.chop}a" }.join(" ") if gender == :feminine
      value += "s" if plurality == :plural
      # Spanish apocope: "primero" / "tercero" drop the final "o" before a masculine singular noun.
      value = value.chop if gender == :masculine && plurality == :singular && value.end_with?("ero")

      value
    else
      I18n.t("#{namespace}.n_#{self}", raise: true)
    end
  rescue I18n::MissingTranslationData
    raise NotImplementedError, "Unknown number #{self} for locale #{I18n.locale}"
  end

  def ordinalize_in_short(gender: :masculine, plurality: :singular)
    abs_number = to_i.abs
    suffix = case I18n.locale
    when :en
      if (11..13).cover?(abs_number % 100)
        "th"
      else
        case abs_number % 10
        when 1 then "st"
        when 2 then "nd"
        when 3 then "rd"
        else "th"
        end
      end
    when :fr
      abs_number == 1 ? "er" : "ème"
    when :it
      "°"
    when :nl
      remainder = abs_number % 100
      [8, 1, 0].include?(remainder) || remainder > 19 ? "ste" : "de"
    when :es
      value = ordinalize_in_full(gender: gender, plurality: plurality)
      ES_SHORT_SUFFIXES.find { |ending, _| value.end_with?(ending) }&.last
    when :de
      gender == :masculine ? "ter" : "te"
    else
      raise NotImplementedError, "Unknown locale #{I18n.locale}"
    end

    [self, suffix].join
  end
end
