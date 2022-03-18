# frozen_string_literal: true

require "i18n"

module OrdinalizeFull
  I18n.load_path += Dir[File.join(__dir__, "ordinalize_precedence/locales/*.yml")]

  def ordinalize(style: :precedence, gender: :masculine, plurality: :singular)
    case style
    when :precedence
      ordinalize_in_precedence(gender: gender, plurality: plurality)
    when :spatial
      ordinalize_in_spatial(gender: gender, plurality: plurality)
    else
      ordinalize_in_short(gender: gender, plurality: plurality)
    end
  end

  def ordinalize_in_precedence(gender: :masculine, plurality: :singular)
    case I18n.locale
    when :fr
      value = I18n.t("ordinalize_precedence.n_#{self}_#{gender}", throw: false, default: "")
      value = I18n.t("ordinalize_precedence.n_#{self}", throw: true) if value.empty?
      value
    when :es
      value = I18n.t("ordinalize_precedence.n_#{self}", throw: false, default: "")

      if value.empty?
        value = [
          I18n.t("ordinalize_precedence.n_#{(self / 10) * 10}", throw: true),
          I18n.t("ordinalize_precedence.n_#{self % 10}", throw: true)
        ].join(" ")
      end

      value = value.split.map { |part| part.chop << "a" }.join(" ") if gender == :feminine
      value << "s" if plurality == :plural
      value = value.chop if value.end_with?("ero")

      value
    when :de
      value = I18n.t("ordinalize_precedence.n_#{self}_#{gender}", throw: false, default: "")
      value = I18n.t("ordinalize_precedence.n_#{self}", throw: true) if value.empty?
      value
    else
      I18n.t("ordinalize_spatial.n_#{self}", throw: true)
    end
  rescue ArgumentError
    raise NotImplementedError, "Unknown locale #{I18n.locale}"
  end

  def ordinalize_in_spatial(gender: :masculine, plurality: :singular)
    case I18n.locale
    when :fr
      value = I18n.t("ordinalize_spatial.n_#{self}_#{gender}", throw: false, default: "")
      value = I18n.t("ordinalize_spatial.n_#{self}", throw: true) if value.empty?
      value
    when :es
      value = I18n.t("ordinalize_spatial.n_#{self}", throw: false, default: "")

      if value.empty?
        value = [
          I18n.t("ordinalize_spatial.n_#{(self / 10) * 10}", throw: true),
          I18n.t("ordinalize_spatial.n_#{self % 10}", throw: true)
        ].join(" ")
      end

      value = value.split.map { |part| part.chop << "a" }.join(" ") if gender == :feminine
      value << "s" if plurality == :plural
      value = value.chop if value.end_with?("ero")

      value
    else
      I18n.t("ordinalize_spatial.n_#{self}", throw: true)
    end
  rescue ArgumentError
    raise NotImplementedError, "Unknown locale #{I18n.locale}"
  end

  alias_method :ordinalize_precedence, :ordinalize_in_precedence
  alias_method :ordinalize_spatial, :ordinalize_in_spatial

private

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
      self == 1 ? "er" : "ème"
    when :it
      "°"
    when :nl
      [8, 1, 0].include?(self % 100) || self % 100 > 19 ? "ste" : "de"
    when :es
      value = ordinalize_in_full(gender: gender, plurality: plurality)

      if value.end_with?("er")
        ".ᵉʳ"
      elsif value.end_with?("a")
        ".ᵃ"
      elsif value.end_with?("o")
        ".ᵒ"
      elsif value.end_with?("os")
        ".ᵒˢ"
      elsif value.end_with?("as")
        ".ᵃˢ"
      end
    when :de
      gender == :masculine ? "ter" : "te"
    end

    [self, suffix].join
  end
end
