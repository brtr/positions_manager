require "rails_helper"

RSpec.describe UserPositionsNotesHistoriesController, type: :controller do
  let(:user) { create(:user) }
  let(:up) { create(:user_position, user_id: user) }
  before do
    sign_in user
    10.times{ create(:user_positions_notes_history, user: user, user_position: up) }
  end
  let(:note) { UserPositionsNotesHistory.first }

  describe "GET index" do
    it "renders a successful response" do
      get :index

      expect(assigns(:histories).count).to eq(10)
      expect(response).to be_successful
      expect(response).to render_template(:index)
    end
  end

  describe "POST create" do
    it "creates a new notes" do
      expect do
        post :create, params: { user_position_id: up.id, user_positions_notes_history: { notes: 'test' } }
      end.to change { UserPositionsNotesHistory.count }.by(1)
    end
  end

  describe "PATCH update" do
    it "renders a successful response" do
      patch :update, params: { id: note.id, user_positions_notes_history: { notes: 'test' } }

      expect(note.reload.notes).to eq('test')
      expect(response.code).to eq ('302')
    end
  end

  describe "DELETE destroy" do
    it "destroy a note" do
      expect do
        delete :destroy, params: { id: note.id }
      end.to change { UserPositionsNotesHistory.count }.by(-1)
    end
  end
end