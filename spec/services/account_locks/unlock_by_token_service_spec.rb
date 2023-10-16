# typed: false

RSpec.describe AccountLocks::UnlockByTokenService do
  subject(:execute) {
    described_class.new.execute(token:)
  }

  let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }
  let(:token) { nil }
  let!(:user_1) {
    create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
  }
  let!(:account_lock) {
    create(:account_lock,
      tenant_id: current_tenant.id,
      user_id: user_1.id,
      email: 'test-user1@example.com',
      failed_attempts: 10,
      unlock_token: '6ed86380c82fb18bed33bb9806eb4d912c84e16b45f8367510e39429d1dbda4c',
      lock_expired_at: 1.minute.from_now,
      last_failed_at: Time.zone.now,)
  }

  before do
    RequestStore.store[:current_tenant_domain] = "#{current_tenant.id}.localhost.com" || '-'
  end


  context 'when token is nil' do
    let(:token) { nil }

    it 'returns false' do
      result = execute
      expect(result).to be false
    end
  end

  context 'when token is vaild' do
    let(:token) { account_lock.unlock_token }

    it 'returns true' do
      result = execute
      expect(result).to be true
    end
  end

  context 'when token has already been used' do
    let(:used_account_lock) {
      al = create(:account_lock,
        tenant_id: current_tenant.id,
        user_id: user_1.id,
        email: 'test-user1@example.com',
        failed_attempts: 10,
        unlock_token: 'fdb5fb62b785c2e649b5865e8cf5f670959762e4b8f14821755c2d683efc69b1',
        lock_expired_at: 1.minute.from_now,
        last_failed_at: Time.zone.now,)
      al.unlock!
      al
    }
    let(:token) { 'fdb5fb62b785c2e649b5865e8cf5f670959762e4b8f14821755c2d683efc69b1' }

    before do
      used_account_lock
    end

    it 'returns false' do
      result = execute
      expect(result).to be false
    end
  end
end
