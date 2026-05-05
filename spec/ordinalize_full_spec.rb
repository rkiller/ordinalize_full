# frozen_string_literal: true

require "ordinalize_full/integer"

describe OrdinalizeFull do
  describe "#ordinalize_in_full" do
    context "with the default locale (:en)" do
      before { I18n.locale = :en }

      specify { expect(1.ordinalize_in_full).to eq("first") }
      specify { expect(42.ordinalize_in_full).to eq("forty second") }

      it "raises with unknown numbers" do
        expect { 101.ordinalize_in_full }.to raise_error(NotImplementedError)
      end
    end

    context "with locale = :fr" do
      before { I18n.locale = :fr }

      specify { expect(1.ordinalize_in_full).to eq("premier") }
      specify { expect(1.ordinalize_in_full(gender: :feminine)).to eq("première") }
      specify { expect(42.ordinalize_in_full).to eq("quarante-deuxième") }
    end

    context "with locale = :nl" do
      before { I18n.locale = :nl }

      specify { expect(1.ordinalize_in_full).to eq("eerste") }
      specify { expect(22.ordinalize_in_full).to eq("tweeëntwintigste") }
    end

    context "with locale = :es" do
      before { I18n.locale = :es }

      specify { expect(1.ordinalize_in_full(gender: :feminine, plurality: :plural)).to eq("primeras") }
      specify { expect(1.ordinalize_in_full).to eq("primer") }
      specify { expect(13.ordinalize_in_full(gender: :feminine, plurality: :plural)).to eq("decimoterceras") }
      specify { expect(13.ordinalize_in_full).to eq("decimotercer") }
      specify { expect(14.ordinalize_in_full(gender: :feminine, plurality: :plural)).to eq("decimocuartas") }
      specify { expect(55.ordinalize_in_full).to eq("quincuagésimo quinto") }
      specify { expect(22.ordinalize_in_full(gender: :feminine, plurality: :plural)).to eq("vigésima segundas") }
      specify { expect(22.ordinalize_in_full(gender: :feminine)).to eq("vigésima segunda") }
      specify { expect(22.ordinalize_in_full(gender: :feminine, plurality: :singular)).to eq("vigésima segunda") }
    end
  end

  describe "#ordinalize_full" do
    specify { expect(1.ordinalize_full).to eq(1.ordinalize_in_full) }
  end

  describe "#ordinalize_in_precedence" do
    context "with the default locale (:en)" do
      before { I18n.locale = :en }

      specify { expect(1.ordinalize_in_precedence).to eq("primary") }
      specify { expect(3.ordinalize_in_precedence).to eq("tertiary") }
      specify { expect(12.ordinalize_in_precedence).to eq("duodenary") }

      it "raises beyond the supported range" do
        expect { 13.ordinalize_in_precedence }.to raise_error(NotImplementedError)
      end
    end

    context "with locale = :fr (no translation data)" do
      before { I18n.locale = :fr }

      it "raises NotImplementedError" do
        expect { 1.ordinalize_in_precedence }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#ordinalize" do
    context "with the default locale (:en)" do
      before { I18n.locale = :en }

      specify { expect(1.ordinalize(in_full: true)).to eq("first") }
      specify { expect(1.ordinalize(in_full: false)).to eq("1st") }

      {
        1 => "1st", 2 => "2nd", 3 => "3rd", 4 => "4th",
        11 => "11th", 12 => "12th", 13 => "13th",
        21 => "21st", 22 => "22nd", 23 => "23rd",
        101 => "101st", 111 => "111th", 113 => "113th",
        0 => "0th", -1 => "-1st", -11 => "-11th"
      }.each do |n, expected|
        specify { expect(n.ordinalize).to eq(expected) }
      end
    end

    context "with locale = :fr" do
      before { I18n.locale = :fr }

      specify { expect(1.ordinalize(in_full: true)).to eq("premier") }
      specify { expect(1.ordinalize(in_full: false)).to eq("1er") }
    end

    context "with locale = :it" do
      before { I18n.locale = :it }

      specify { expect(1.ordinalize(in_full: true)).to eq("primo") }
      specify { expect(1.ordinalize(in_full: false)).to eq("1°") }
    end

    context "with locale = :nl" do
      before { I18n.locale = :nl }

      specify { expect(1.ordinalize(in_full: true)).to eq("eerste") }
      specify { expect(1.ordinalize(in_full: false)).to eq("1ste") }
    end

    context "with locale = :es" do
      before { I18n.locale = :es }

      specify { expect(1.ordinalize(gender: :feminine, plurality: :plural)).to eq("1.ᵃˢ") }
      specify { expect(1.ordinalize).to eq("1.ᵉʳ") }
      specify { expect(13.ordinalize(gender: :feminine, plurality: :plural)).to eq("13.ᵃˢ") }
      specify { expect(13.ordinalize).to eq("13.ᵉʳ") }
      specify { expect(14.ordinalize(gender: :feminine, plurality: :plural)).to eq("14.ᵃˢ") }
      specify { expect(55.ordinalize).to eq("55.ᵒ") }
      specify { expect(22.ordinalize(gender: :feminine, plurality: :plural)).to eq("22.ᵃˢ") }
    end

    context "with an unsupported locale" do
      around do |example|
        previous = I18n.enforce_available_locales
        I18n.enforce_available_locales = false
        I18n.locale = :ja
        example.run
        I18n.enforce_available_locales = previous
        I18n.locale = :en
      end

      it "raises NotImplementedError" do
        expect { 1.ordinalize }.to raise_error(NotImplementedError)
      end
    end

    context "with invalid keyword arguments" do
      before { I18n.locale = :en }

      it "raises ArgumentError on unknown gender" do
        expect { 1.ordinalize(gender: :neuter) }.to raise_error(ArgumentError, /gender/)
      end

      it "raises ArgumentError on unknown plurality" do
        expect { 1.ordinalize(plurality: :dual) }.to raise_error(ArgumentError, /plurality/)
      end

      it "raises ArgumentError from ordinalize_in_full" do
        expect { 1.ordinalize_in_full(gender: :neuter) }.to raise_error(ArgumentError)
      end
    end
  end
end
