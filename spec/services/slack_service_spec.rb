# frozen_string_literal: true

require "rails_helper"

RSpec.describe SlackService, type: :service do
  describe "#send_notification" do
    before do
      allow(Rails).to receive_message_chain(:env, :production?).and_return true
    end
    let(:blocks) {
      [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "价格变动提醒"
          }
        }
      ]
    }

    context "when have env" do
      before do
        ENV["SLACK_MONITOR_CHANNEL"] = "http://test.slack.com/"
      end

      it "invoke http post method" do
        expect(Net::HTTP).to receive(:post)
        described_class.send_notification(nil, blocks)
      end

      it "return nil with no text" do
        result = described_class.send_notification(nil,nil)
        expect(result).to be nil
      end
    end
  end
end
