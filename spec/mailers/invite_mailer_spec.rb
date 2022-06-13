RSpec.describe InviteMailer, type: :mailer do
  describe '.invite_user' do
    subject { InviteMailer.invite_user(invite) }

    let(:invite) { create(:invite, user: create(:user)) }
    it do
      expect { subject.body }
        .to change { TargetedUserLink.where(target_model: invite, user: invite.user).count }
        .from(0).to(1)
    end
  end

  describe '.invite_guest' do
    subject { InviteMailer.invite_guest(invite) }

    let(:invite) { create(:invite, user: nil, email: 'kikoo@lol.fr') }
    it do
      expect { subject.body }
        .to change { TargetedUserLink.where(target_model: invite, user: nil).count }
        .from(0).to(1)
    end
  end
end
