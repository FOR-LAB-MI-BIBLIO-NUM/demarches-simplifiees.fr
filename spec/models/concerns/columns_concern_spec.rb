# frozen_string_literal: true

describe ColumnsConcern do
  describe '#find_column' do
    let(:procedure) { build(:procedure) }
    let(:notifications_column) { procedure.notifications_column }

    it do
      label = notifications_column.label
      expect(procedure.find_column(label:)).to eq(notifications_column)

      h_id = notifications_column.h_id
      expect(procedure.find_column(h_id:)).to eq(notifications_column)

      unknwon = 'unknown'
      expect { procedure.find_column(h_id: unknwon) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#columns" do
    subject { procedure.columns }

    context 'when the procedure can have a SIRET number' do
      let(:procedure) { create(:procedure, types_de_champ_public:, types_de_champ_private:) }
      let(:procedure_id) { procedure.id }
      let(:tdc_1) { procedure.active_revision.types_de_champ_public[0] }
      let(:tdc_2) { procedure.active_revision.types_de_champ_public[1] }
      let(:tdc_private_1) { procedure.active_revision.types_de_champ_private[0] }
      let(:tdc_private_2) { procedure.active_revision.types_de_champ_private[1] }
      let(:expected) {
        [
          { label: 'Dossier ID', table: 'self', column: 'id', displayable: true, type: :number, value_column: :value, filterable: true },
          { label: 'notifications', table: 'notifications', column: 'notifications', displayable: true, type: :text, value_column: :value, filterable: false },
          { label: 'Date de création', table: 'self', column: 'created_at', displayable: true, type: :date, value_column: :value, filterable: true },
          { label: 'Mis à jour le', table: 'self', column: 'updated_at', displayable: true, type: :date, value_column: :value, filterable: true },
          { label: 'Date de dépot', table: 'self', column: 'depose_at', displayable: true, type: :date, value_column: :value, filterable: true },
          { label: 'En construction le', table: 'self', column: 'en_construction_at', displayable: true, type: :date, value_column: :value, filterable: true },
          { label: 'En instruction le', table: 'self', column: 'en_instruction_at', displayable: true, type: :date, value_column: :value, filterable: true },
          { label: 'Terminé le', table: 'self', column: 'processed_at', displayable: true, type: :date, value_column: :value, filterable: true },
          { label: "Dernier évènement depuis", table: "self", column: "updated_since", displayable: false, type: :date, value_column: :value, filterable: true },
          { label: "Déposé depuis", table: "self", column: "depose_since", displayable: false, type: :date, value_column: :value, filterable: true },
          { label: "En construction depuis", table: "self", column: "en_construction_since", displayable: false, type: :date, value_column: :value, filterable: true },
          { label: "En instruction depuis", table: "self", column: "en_instruction_since", displayable: false, type: :date, value_column: :value, filterable: true },
          { label: "Traité depuis", table: "self", column: "processed_since", displayable: false, type: :date, value_column: :value, filterable: true },
          { label: "Statut", table: "self", column: "state", displayable: false, type: :enum, value_column: :value, filterable: true },
          { label: "Archivé", table: "self", column: "archived", displayable: false, type: :text, value_column: :value, filterable: false },
          { label: "Motivation de la décision", table: "self", column: "motivation", displayable: false, type: :text, value_column: :value, filterable: false },
          { label: "Date de dernière modification (usager)", table: "self", column: "last_champ_updated_at", displayable: false, type: :text, value_column: :value, filterable: false },
          { label: 'Demandeur', table: 'user', column: 'email', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'Email instructeur', table: 'followers_instructeurs', column: 'email', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'Groupe instructeur', table: 'groupe_instructeur', column: 'id', displayable: true, type: :enum, value_column: :value, filterable: true },
          { label: 'Avis oui/non', table: 'avis', column: 'question_answer', displayable: true, type: :text, value_column: :value, filterable: false },
          { label: 'France connecté ?', table: 'self', column: 'user_from_france_connect?', displayable: false, type: :text, value_column: :value, filterable: false },
          { label: "Labels", table: "dossier_labels", column: "label_id", displayable: true, value_column: :value, filterable: true },
          { label: 'SIREN', table: 'etablissement', column: 'entreprise_siren', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'Forme juridique', table: 'etablissement', column: 'entreprise_forme_juridique', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'Nom commercial', table: 'etablissement', column: 'entreprise_nom_commercial', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'Raison sociale', table: 'etablissement', column: 'entreprise_raison_sociale', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'SIRET siège social', table: 'etablissement', column: 'entreprise_siret_siege_social', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'Date de création', table: 'etablissement', column: 'entreprise_date_creation', displayable: true, type: :date, value_column: :value, filterable: true },
          { label: 'SIRET', table: 'etablissement', column: 'siret', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'Libellé NAF', table: 'etablissement', column: 'libelle_naf', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: 'Code postal', table: 'etablissement', column: 'code_postal', displayable: true, type: :text, value_column: :value, filterable: true },
          { label: tdc_1.libelle, table: 'type_de_champ', column: tdc_1.stable_id.to_s, displayable: true, type: :text, value_column: :value, filterable: true },
          { label: tdc_2.libelle, table: 'type_de_champ', column: tdc_2.stable_id.to_s, displayable: true, type: :text, value_column: :value, filterable: true },
          { label: tdc_private_1.libelle, table: 'type_de_champ', column: tdc_private_1.stable_id.to_s, displayable: true, type: :text, value_column: :value, filterable: true },
          { label: tdc_private_2.libelle, table: 'type_de_champ', column: tdc_private_2.stable_id.to_s, displayable: true, type: :text, value_column: :value, filterable: true }
        ].map { Column.new(**_1.merge(procedure_id:)) }
      }

      context 'with explication/header_sections' do
        let(:types_de_champ_public) { Array.new(4) { { type: :text } } }
        let(:types_de_champ_private) { Array.new(4) { { type: :text } } }
        before do
          procedure.active_revision.types_de_champ_public[2].update_attribute(:type_champ, TypeDeChamp.type_champs.fetch(:header_section))
          procedure.active_revision.types_de_champ_public[3].update_attribute(:type_champ, TypeDeChamp.type_champs.fetch(:explication))
          procedure.active_revision.types_de_champ_private[2].update_attribute(:type_champ, TypeDeChamp.type_champs.fetch(:header_section))
          procedure.active_revision.types_de_champ_private[3].update_attribute(:type_champ, TypeDeChamp.type_champs.fetch(:explication))
        end

        it {
          expected.each do |expected|
            expect(subject).to include(expected)
          end
        }
      end

      context 'with rna' do
        let(:types_de_champ_public) { [{ type: :rna, libelle: 'rna' }] }
        let(:types_de_champ_private) { [] }
        it { expect(subject.map(&:label)).to include('rna – commune') }
      end

      context 'with linked drop down list' do
        let(:types_de_champ_public) { [{ type: :linked_drop_down_list, libelle: 'linked' }] }
        let(:types_de_champ_private) { [] }
        it {
          expect(subject.map(&:label)).to include('linked (Primaire)')
          expect(subject.map(&:label)).to include('linked (Secondaire)')
        }
      end
    end

    context 'when the procedure is for individuals' do
      let(:name_field) { Column.new(procedure_id:, label: "Prénom", table: "individual", column: "prenom", displayable: true, type: :text, value_column: :value, filterable: true) }
      let(:surname_field) { Column.new(procedure_id:, label: "Nom", table: "individual", column: "nom", displayable: true, type: :text, value_column: :value, filterable: true) }
      let(:gender_field) { Column.new(procedure_id:, label: "Civilité", table: "individual", column: "gender", displayable: true, type: :text, value_column: :value, filterable: true) }
      let(:procedure) { create(:procedure, :for_individual) }
      let(:procedure_id) { procedure.id }
      let(:procedure_presentation) { create(:procedure_presentation, assign_to: assign_to) }

      it { is_expected.to include(name_field, surname_field, gender_field) }
    end

    context 'when the procedure is sva' do
      let(:procedure) { create(:procedure, :for_individual, :sva) }
      let(:procedure_id) { procedure.id }
      let(:procedure_presentation) { create(:procedure_presentation, assign_to: assign_to) }

      let(:decision_on) { Column.new(procedure_id:, label: "Date décision SVA", table: "self", column: "sva_svr_decision_on", displayable: true, type: :date, value_column: :value, filterable: true) }
      let(:decision_before_field) { Column.new(procedure_id:, label: "Date décision SVA avant", table: "self", column: "sva_svr_decision_before", displayable: false, type: :date, value_column: :value, filterable: true) }

      it { is_expected.to include(decision_on, decision_before_field) }
    end

    context 'when the procedure is svr' do
      let(:procedure) { create(:procedure, :for_individual, :svr) }
      let(:procedure_id) { procedure.id }
      let(:procedure_presentation) { create(:procedure_presentation, assign_to: assign_to) }

      let(:decision_on) { Column.new(procedure_id:, label: "Date décision SVR", table: "self", column: "sva_svr_decision_on", displayable: true, type: :date, value_column: :value, filterable: true) }
      let(:decision_before_field) { Column.new(procedure_id:, label: "Date décision SVR avant", table: "self", column: "sva_svr_decision_before", displayable: false, type: :date, value_column: :value, filterable: true) }

      it { is_expected.to include(decision_on, decision_before_field) }
    end

    context 'when the procedure has several groupe instructeur' do
      let(:procedure) { create(:procedure, :routee) }
      let(:groupe_1) { procedure.groupe_instructeurs.first }
      let(:groupe_2) { procedure.groupe_instructeurs.last }
      let(:groupe_instructeur_column) { procedure.find_column(label: "Groupe instructeur") }

      context 'and no instructeur is available in current' do
        it { expect(groupe_instructeur_column.options_for_select).to eq([]) }
      end

      context 'and instructeur is available in current' do
        let(:instructeur) { create(:instructeur) }

        before do
          procedure.groupe_instructeurs.each { _1.add(instructeur) }
          allow(Current).to receive(:user).and_return(instructeur.user)
        end

        it { expect(groupe_instructeur_column.options_for_select).to match_array([groupe_1, groupe_2].map { [_1.label, _1.id] }) }
      end
    end
  end

  describe 'export' do
    let(:procedure) { create(:procedure_with_dossiers, :published, types_de_champ_public:, for_individual:) }
    let(:for_individual) { true }
    let(:types_de_champ_public) do
      [
        { type: :text, libelle: "Ca va ?", mandatory: true, stable_id: 1 },
        { type: :communes, libelle: "Commune", mandatory: true, stable_id: 17 },
        { type: :siret, libelle: 'siret', stable_id: 20 },
        { type: :repetition, mandatory: true, stable_id: 7, libelle: "Champ répétable", children: [{ type: 'text', libelle: 'Qqchose à rajouter?', stable_id: 8 }] }
      ]
    end

    describe '#usager_columns_for_export' do
      context 'for individual procedure' do
        let(:for_individual) { true }

        it "returns all usager columns" do
          expected = [
            procedure.find_column(label: "Nº dossier"),
            procedure.find_column(label: "Email"),
            procedure.find_column(label: "France connecté ?"),
            procedure.find_column(label: "Civilité"),
            procedure.find_column(label: "Nom"),
            procedure.find_column(label: "Prénom"),
            procedure.find_column(label: "Dépôt pour un tiers"),
            procedure.find_column(label: "Nom du mandataire"),
            procedure.find_column(label: "Prénom du mandataire")
          ]
          actuals = procedure.usager_columns_for_export.map(&:h_id)
          expected.each do |expected_col|
            expect(actuals).to include(expected_col.h_id)
          end
        end
      end

      context 'for entreprise procedure' do
        let(:for_individual) { false }

        it "returns all usager columns" do
          expected = [
            procedure.find_column(label: "Nº dossier"),
            procedure.find_column(label: "Email"),
            procedure.find_column(label: "France connecté ?"),
            procedure.find_column(label: "Établissement SIRET"),
            procedure.find_column(label: "Établissement siège social"),
            procedure.find_column(label: "Établissement NAF"),
            procedure.find_column(label: "Libellé NAF"),
            procedure.find_column(label: "Établissement Adresse"),
            procedure.find_column(label: "Établissement numero voie"),
            procedure.find_column(label: "Établissement type voie"),
            procedure.find_column(label: "Établissement nom voie"),
            procedure.find_column(label: "Établissement complément adresse"),
            procedure.find_column(label: "Établissement code postal"),
            procedure.find_column(label: "Établissement localité"),
            procedure.find_column(label: "Établissement code INSEE localité"),
            procedure.find_column(label: "Entreprise SIREN"),
            procedure.find_column(label: "Entreprise capital social"),
            procedure.find_column(label: "Entreprise numero TVA intracommunautaire"),
            procedure.find_column(label: "Entreprise forme juridique"),
            procedure.find_column(label: "Entreprise forme juridique code"),
            procedure.find_column(label: "Entreprise nom commercial"),
            procedure.find_column(label: "Entreprise raison sociale"),
            procedure.find_column(label: "Entreprise SIRET siège social"),
            procedure.find_column(label: "Entreprise code effectif entreprise")
          ]
          actuals = procedure.usager_columns_for_export
          expected.each do |expected_col|
            expect(actuals.map(&:h_id)).to include(expected_col.h_id)
          end

          expect(actuals.any? { _1.label == "Nom" }).to eq false
        end
      end

      context 'when procedure chorusable' do
        let(:procedure) { create(:procedure_with_dossiers, :filled_chorus, types_de_champ_public:) }
        it 'returns specific chorus columns' do
          allow_any_instance_of(Procedure).to receive(:chorusable?).and_return(true)
          expected = [
            procedure.find_column(label: "Domaine Fonctionnel"),
            procedure.find_column(label: "Référentiel De Programmation"),
            procedure.find_column(label: "Centre De Coût")
          ]
          actuals = procedure.usager_columns_for_export.map(&:h_id)
          expected.each do |expected_col|
            expect(actuals).to include(expected_col.h_id)
          end
        end
      end
    end

    describe '#dossier_columns_for_export' do
      let(:procedure) { create(:procedure_with_dossiers, :routee, :published, types_de_champ_public:, for_individual:) }

      it "returns all dossier columns" do
        expected = [
          procedure.find_column(label: "Archivé"),
          procedure.find_column(label: "État du dossier"),
          procedure.find_column(label: "Date du dernier évènement"),
          procedure.find_column(label: "Date de dernière modification (usager)"),
          procedure.find_column(label: "Date de dépot"),
          procedure.find_column(label: "Date de passage en instruction"),
          procedure.find_column(label: "Date de traitement"),
          procedure.find_column(label: "Motivation de la décision"),
          procedure.find_column(label: "Instructeurs"),
          procedure.find_column(label: "Groupe instructeur")
        ]
        actuals = procedure.dossier_columns_for_export.map(&:h_id)
        expected.each do |expected_col|
          expect(actuals).to include(expected_col.h_id)
        end
      end
    end
  end
end
