# typed: false

RSpec.describe '[ Password API ]' do
  describe 'POST /api/v1/authentication/passwords' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }

    before do
      current_user
    end

    context 'when no session' do
      let(:params) {
        {
          user: {
            password: 'This_is_password1234',
          },
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when password already seted' do
      let(:current_user) {
        create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'This_is_past_password1234')
      }
      let(:params) {
        {
          user: {
            password: 'This_is_password1234',
          },
        }
      }

      let(:session_mock) {
        instance_double(ExpirableCookie)
      }

      before do
        allow(ExpirableCookie).to receive(:new).and_return(session_mock)
        allow(session_mock).to receive(:[]=).and_return(nil)
        allow(session_mock).to receive(:session_clear).and_return(nil)
        allow(session_mock).to receive(:[]) do |key|
          case key
          when :current_user_id, :current_user_id_expired_at
            nil
          when :registering_user_id
            current_user.id
          when :registering_user_id_expired_at
            1.week.from_now
          end
        end
      end

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when present session' do
      let(:session_mock) {
        instance_double(ExpirableCookie)
      }

      before do
        allow(ExpirableCookie).to receive(:new).and_return(session_mock)
        allow(session_mock).to receive(:[]=).and_return(nil)
        allow(session_mock).to receive(:session_clear).and_return(nil)
        allow(session_mock).to receive(:[]) do |key|
          case key
          when :current_user_id, :current_user_id_expired_at
            nil
          when :registering_user_id
            current_user.id
          when :registering_user_id_expired_at
            1.week.from_now
          end
        end
      end


      context 'when password vaild' do
        let(:params) {
          {
            user: {
              password: 'This_is_password1234!',
            },
          }
        }

        it 'returns 204' do
          is_expected.to eq 204
        end
      end

      context 'when password dont has lower case' do
        let(:params) {
          {
            user: {
              password: 'THIS_IS_PASSWORD1234!',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end

      context 'when password dont has upper case' do
        let(:params) {
          {
            user: {
              password: 'this_is_password1234!',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end


      context 'when password dont has number' do
        let(:params) {
          {
            user: {
              password: 'This_is_password!',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end

      context 'when password dont has ASCII code symbols' do
        let(:params) {
          {
            user: {
              password: 'Thisispassword1234',
            },
          }
        }

        it 'returns 204' do
          is_expected.to eq 204
        end
      end

      context 'when password less than 8 words' do
        let(:params) {
          {
            user: {
              password: 'Th1!',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end

      context 'when password more than 100 words' do
        let(:params) {
          {
            user: {
              password: 'This_is_password1234!1234123456789012341234567890123412345678901234123456789012341234567890123412345678901234123456789012341234567890',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end
    end
  end

  describe 'PUT /api/v1/authentication/passwords' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'This_is_past_password1234')
    }

    before do
      current_user
    end

    context 'when no session' do
      let(:params) {
        {
          user: {
            password: 'This_is_password1234',
          },
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      include_context 'current user session is present'

      context 'when password vaild' do
        let(:params) {
          {
            user: {
              password: 'This_is_password1234!',
            },
          }
        }

        it 'returns 204' do
          is_expected.to eq 204
        end
      end

      context 'when password dont has lower case' do
        let(:params) {
          {
            user: {
              password: 'THIS_IS_PASSWORD1234!',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end

      context 'when password dont has upper case' do
        let(:params) {
          {
            user: {
              password: 'this_is_password1234!',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end


      context 'when password dont has number' do
        let(:params) {
          {
            user: {
              password: 'This_is_password!',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end

      context 'when password dont has ASCII code symbols' do
        let(:params) {
          {
            user: {
              password: 'Thisispassword1234',
            },
          }
        }

        it 'returns 204' do
          is_expected.to eq 204
        end
      end

      context 'when password less than 8 words' do
        let(:params) {
          {
            user: {
              password: 'Th1!',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end

      context 'when password more than 100 words' do
        let(:params) {
          {
            user: {
              password: 'This_is_password1234!1234123456789012341234567890123412345678901234123456789012341234567890123412345678901234123456789012341234567890',
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end
    end
  end
end
