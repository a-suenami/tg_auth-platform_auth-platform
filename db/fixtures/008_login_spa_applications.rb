LoginSpaApplication.seed do |s|
  s.id = 'bb1839be-3a5b-4411-a947-eebae7f78d63'
  s.name = 'Login SPA Application 1'
  s.tenant_id = 'sample'
  s.uid = 'oauth|sample|1234567'
  s.login_url = 'http://localhost:3000/login'
  s.sign_up_url = 'http://localhost:3000/sign_up'
  s.redirect_url_on_password_reset = 'http://localhost:3000/password_resets/edit'
end
