require 'spec_helper'

describe Gitlab::ChatCommands::Presenters::IssueShow do
  let(:project) { create(:empty_project) }
  let(:issue) { create(:issue, project: project) }
  let(:attachment) { subject[:attachments].first }

  subject { described_class.new(issue).present }

  it { is_expected.to be_a(Hash) }

  it 'shows the issue' do
    expect(subject[:response_type]).to be(:in_channel)
    expect(subject).to have_key(:attachments)
    expect(attachment[:title]).to start_with(issue.title)
  end

  context 'with upvotes' do
    before do
      create(:award_emoji, :upvote, awardable: issue)
    end

    it 'shows the upvote count' do
      expect(subject[:response_type]).to be(:in_channel)
      expect(attachment[:text]).to start_with("**Open** · :+1: 1")
    end
  end

  context 'confidential issue' do
    let(:issue) { create(:issue, project: project) }

    it 'shows an ephemeral response' do
      expect(subject[:response_type]).to be(:in_channel)
      expect(attachment[:text]).to start_with("**Open**")
    end
  end

  context 'issue with issue weight' do
    let(:issue) { create(:issue, project: project, weight: 3) }
    let(:weight_attachment) { subject[:attachments].first[:fields].find { |a| a[:title] == "Weight" } }

    it 'shows the weight' do
      expect(weight_attachment).not_to eq(nil)
      expect(weight_attachment[:value]).to be(3)
    end
  end
end
