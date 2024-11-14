# frozen_string_literal: true

describe TypesDeChamp::CommuneTypeDeChamp do
  let(:tdc_commune) { create(:type_de_champ_communes, libelle: 'Ma commune') }
  it { expect(tdc_commune.libelles_for_export).to match_array([['Ma commune', :value], ['Ma commune (Code INSEE)', :code], ['Ma commune (Département)', :departement]]) }
end
