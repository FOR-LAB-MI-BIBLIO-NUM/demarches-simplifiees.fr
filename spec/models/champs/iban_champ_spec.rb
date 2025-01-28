# frozen_string_literal: true

describe Champs::IbanChamp do
  let(:types_de_champ_public) { [{ type: :iban }] }
  let(:procedure) { create(:procedure, types_de_champ_public:) }
  let(:dossier) { create(:dossier, procedure:) }
  let(:champ) { dossier.champs.first }

  describe '#valid?' do
    def with_value(value)
      champ.tap { _1.value = value }
    end
    it do
      expect(with_value(nil).valid?(:champs_public_value)).to be_truthy
      expect(with_value("FR35 KDSQFDJQSMFDQMFDQ").valid?(:champs_public_value)).to be_falsey
      expect(with_value("FR7630006000011234567890189").valid?(:champs_public_value)).to be_truthy
      expect(with_value("FR76 3000 6000 0112 3456 7890 189").valid?(:champs_public_value)).to be_truthy
      expect(with_value("FR76 3000 6000 0112 3456 7890 189DSF").valid?(:champs_public_value)).to be_falsey
      expect(with_value("FR76	3000	6000	0112	3456	7890	189").valid?(:champs_public_value)).to be_truthy
    end

    it 'format value after validation' do
      with_value("FR76	3000	6000	0112	3456	7890	189")
      champ.valid?(:champs_public_value)
      expect(champ.value).to eq("FR76 3000 6000 0112 3456 7890 189")
    end
  end
end
