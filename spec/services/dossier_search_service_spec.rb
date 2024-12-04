# frozen_string_literal: true

describe DossierSearchService do
  describe '#matching_dossiers' do
    let!(:dossiers) { Dossier.where(id: dossier.id) }

    before { perform_enqueued_jobs(only: DossierIndexSearchTermsJob) }

    def searching(terms) = described_class.matching_dossiers(dossiers, terms)

    describe 'ignores brouillon' do
      let(:dossier) { create(:dossier, state: :brouillon) }

      it { expect(searching(dossier.id.to_s)).to eq([]) }
    end

    context 'with a dossier not in brouillon' do
      let(:user) { create(:user, email: 'nicolas@email.com') }
      let(:etablissement) { create(:etablissement, entreprise_raison_sociale: 'Direction Interministerielle Du Numérique', siret: '13002526500013') }
      let(:dossier) do
        create(:dossier, state: :en_construction, user:, etablissement:).tap do |dossier|
          dossier.champs.first.update!(value: 'Hélène mange des pommes')
        end
      end

      it do
        expect(searching('')).to eq([])

        # by dossier id
        expect(searching(dossier.id.to_s)).to eq([dossier.id])

        # by email
        expect(searching('nicolas@email.com')).to eq([dossier.id])
        expect(searching('nicolas')).to eq([dossier.id])

        # by SIRET
        expect(searching('13002526500013')).to eq([dossier.id])
        expect(searching('1300')).to eq([dossier.id])

        # by raison sociale
        expect(searching('Direction Interministerielle Du Numérique')).to eq([dossier.id])
        expect(searching('Direction')).to eq([dossier.id])

        # with multiple terms
        expect(searching('Direction nicolas')).to eq([dossier.id])

        # with forbidden characters
        expect(searching("'?\\:&!(Direction) <Interministerielle>")).to eq([dossier.id])

        # with a single forbidden character should not crash postgres
        expect(searching('? Direction')).to eq([dossier.id])

        # with supirious spaces
        expect(searching("  nicolas  ")).to eq([dossier.id])

        # with wrong case
        expect(searching('direction')).to eq([dossier.id])

        # by champ text
        expect(searching('Hélène')).to eq([dossier.id])

        # by singular
        expect(searching('la pomme')).to eq([dossier.id])

        # without accent
        expect(searching('helene')).to eq([dossier.id])

        # NOT WORKING YET
        # with a single faulty character
        expect(searching('des pammes')).to eq([])
      end
    end

    describe 'does not ignore archived dossiers' do
      let(:dossier) { create(:dossier, state: :en_construction, archived: true) }

      it { expect(searching(dossier.id.to_s)).to eq([dossier.id]) }
    end
  end

  describe '#matching_dossiers_for_user' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }

    before { perform_enqueued_jobs(only: DossierIndexSearchTermsJob) }

    def searching(terms, user) = described_class.matching_dossiers_for_user(terms, user)

    context 'when the dossier is brouillon' do
      let(:dossier) { create(:dossier, state: :brouillon, user:) }

      it do
        # searching its own dossier by id
        expect(searching(dossier.id.to_s, user)).to eq([dossier])

        # searching another dossier by id
        expect(searching(dossier.id.to_s, another_user)).to eq([])
      end
    end

    context 'when the user is invited on the dossier' do
      let(:dossier) { create(:dossier) }

      before { create(:invite, dossier:, user:) }

      it { expect(searching(dossier.id.to_s, user)).to eq([dossier]) }
    end
  end
end
