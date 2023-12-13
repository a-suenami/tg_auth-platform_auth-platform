# typed: false

RSpec.describe '[ Logout API ]' do
  describe 'POST /api/v1/authentication/logout' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
    }

    before do
      current_user
    end

    context 'when no session' do
      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      include_context 'current user session is present'

      it 'returns 204' do
        is_expected.to eq 204
        expect(session_mock).to have_received(:session_clear)
      end
    end

    context 'when present old session && cookie_domain_remove_length is 0' do
      include_context 'current user session is present'
      let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', cookie_domain_remove_length: 0) }

      let(:headers) {
        {
          "Cookie" => "_rails_app_session=R7Sn2dHuJwPakROI1Jsg4hGFv5JvQg5kkUo4qfzjwkK4L8oh9OAzclZNyPEemQI0%2FI36ij5fmQuYgMzf7HwsrFwYIJnmsKi8nf4sNqrjpthzZwo7REupVtCR11V6HaVOBd1g1ojQJXMz3xb7wMR8iSYMZojpYXCNJYEIzo67sYCuAn7dVCKOdughXjYGOz%2FHvEG2JW6%2F8DqKWaMv0i7o2y7dH6mUye1gY5hzCIKYxDGwGh4q9%2B9CSQuJZCUdtRu7V9bGdLTqd9pkfup2Yd3hNGhkk2prZ5Kp5RQ%2FRrOzddfmNze5Mu9mbxrn2q2VvGH04KPwi9jlAxpuxmKwfRndRwEjZj5AKCEvZtMjCgBRl0k4%2FCRiQzdjHMQBFDLcSdzRHN%2FCs%2Blp--iTErSVy1gILZryf3--1j77WX3GdnmMzY4BB%2FkOqw%3D%3D; _rails_app_session=PQax5Hy5P0iQK8%2FOYj%2F8B6s1dyuu%2FgfEAZgOlbNgYe%2FSDSGQ796iKYHHnCK2PlcTvUNwVTEyTFO6RF%2BOdyNQkqPY16BJ0dAeN2vzclojc6hIpJW14iNwp%2BE3TYB2wtrn86yj9jW1OgtbCo7oira4yXDYLuAgPua5NN3zNvbiPCKKlX7xEFnKAW7Ap1rYIXLAnfPgGmRnFtudLRulDqsKXPQZ9bosamUvmR28s4fWLcOkjPDcyHDLT5ITPEeJrKJJCtMH0yIwpT1%2F8PiqZsn8W9PV5K5TEW%2B8QR%2B1nEUxsI67ks57nWeSesQk7uSvQlGBd%2FL5u0k5C%2BhfU88lI7IKcecYi0Yr7U3AXh%2F7uKnQYeW%2FCNDBpAOVAIQ%2FTYbpFTf6lR%2F7Yk94--YlW1s2Ln67RFQm%2Fd--VgEMIsgftCDZwoRY36dprQ%3D%3D"
        }
      }

      it 'returns 204' do
        is_expected.to eq 204
        expect(session_mock).to have_received(:session_clear)
        expect(response.get_header('Set-Cookie').match(/domain=([^;]+)/)[1]).to eq 'localhost.com'
      end
    end

    context 'when present old session && cookie_domain_remove_length is 1' do
      include_context 'current user session is present'
      let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', cookie_domain_remove_length: 1) }

      let(:headers) {
        {
          "Cookie" => "_rails_app_session=R7Sn2dHuJwPakROI1Jsg4hGFv5JvQg5kkUo4qfzjwkK4L8oh9OAzclZNyPEemQI0%2FI36ij5fmQuYgMzf7HwsrFwYIJnmsKi8nf4sNqrjpthzZwo7REupVtCR11V6HaVOBd1g1ojQJXMz3xb7wMR8iSYMZojpYXCNJYEIzo67sYCuAn7dVCKOdughXjYGOz%2FHvEG2JW6%2F8DqKWaMv0i7o2y7dH6mUye1gY5hzCIKYxDGwGh4q9%2B9CSQuJZCUdtRu7V9bGdLTqd9pkfup2Yd3hNGhkk2prZ5Kp5RQ%2FRrOzddfmNze5Mu9mbxrn2q2VvGH04KPwi9jlAxpuxmKwfRndRwEjZj5AKCEvZtMjCgBRl0k4%2FCRiQzdjHMQBFDLcSdzRHN%2FCs%2Blp--iTErSVy1gILZryf3--1j77WX3GdnmMzY4BB%2FkOqw%3D%3D; _rails_app_session=PQax5Hy5P0iQK8%2FOYj%2F8B6s1dyuu%2FgfEAZgOlbNgYe%2FSDSGQ796iKYHHnCK2PlcTvUNwVTEyTFO6RF%2BOdyNQkqPY16BJ0dAeN2vzclojc6hIpJW14iNwp%2BE3TYB2wtrn86yj9jW1OgtbCo7oira4yXDYLuAgPua5NN3zNvbiPCKKlX7xEFnKAW7Ap1rYIXLAnfPgGmRnFtudLRulDqsKXPQZ9bosamUvmR28s4fWLcOkjPDcyHDLT5ITPEeJrKJJCtMH0yIwpT1%2F8PiqZsn8W9PV5K5TEW%2B8QR%2B1nEUxsI67ks57nWeSesQk7uSvQlGBd%2FL5u0k5C%2BhfU88lI7IKcecYi0Yr7U3AXh%2F7uKnQYeW%2FCNDBpAOVAIQ%2FTYbpFTf6lR%2F7Yk94--YlW1s2Ln67RFQm%2Fd--VgEMIsgftCDZwoRY36dprQ%3D%3D"
        }
      }

      it 'returns 204' do
        is_expected.to eq 204
        expect(session_mock).to have_received(:session_clear)
        expect(response.get_header('Set-Cookie').match(/domain=([^;]+)/)[1]).to eq 'sample.localhost.com'
      end
    end
  end
end
