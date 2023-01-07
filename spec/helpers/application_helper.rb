require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#position_amount_display' do
    let(:up) { create(:user_position) }

    it 'returns position amount without margin' do
      expect(helper.position_amount_display(up)).to eq("30.7202 USDT")
    end

    context "with snapshot" do
      let(:info) { create(:snapshot_info) }

      it 'returns position amount with margin' do
        snapshot = create(:snapshot_position, snapshot_info: info)
  
        expect(helper.position_amount_display(up, snapshot)).to eq("30.7202 USDT(<span class=neg-num>-35.0799</span>)")
      end
  
      it 'returns position amount without margin when margin not valid' do
        snapshot = create(:snapshot_position, snapshot_info: info, amount: 30)
  
        expect(helper.position_amount_display(up, snapshot)).to eq("30.7202 USDT")
      end
    end
  end
end