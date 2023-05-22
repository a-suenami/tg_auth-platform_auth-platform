# seed oauth applications
Doorkeeper::Application.seed do |s|
  s.id = '40ce3073-75a6-4c47-8ebd-6a4fde3f81be'
  s.uid = '7s29N_Ro1IjSp50dtjLyB15u026Zk7G24pCz0Oy70XI'
  s.secret = 'leV04prfWVBOgfmALi2wtls8ACecpw09TUGXyrAAEIs'
  s.tenant_id = 'sample'
  s.name = 'Sample Application'
  s.redirect_uri = 'http://localhost:4200/oauth/callback'
  s.confidential = false
end

Doorkeeper::Application.seed do |s|
  s.id = '51667e97-1eea-4ad2-b60e-e59d24a2cf43'
  s.uid = 'HYUfKbGiS-6B0y9gWx6iI705LqJBmNT8TtVBkbC4I1A'
  s.secret = 'zH1TtAnSBB3y0OQcWOQIJyw4OyXKT34FkvPM9qebt0M'
  s.tenant_id = 'twogate'
  s.name = 'Twogate Application'
  s.redirect_uri = 'http://localhost:4200/oauth/callback'
  s.confidential = false
end

Doorkeeper::Application.seed do |s|
  s.id = '48213048-1839-4429-b9c5-4c801b767321'
  s.uid = 'gd1dy__aQqiaA3izY26nkdU68eHDBNxMyxTQwJAzM2M'
  s.secret = 'k4k3VLIBX9ahRXBUW61uO8-tEsR1cLDzQvTrSPKUz6Q'
  s.tenant_id = 'sample'
  s.name = 'Admin Application'
  s.redirect_uri = 'http://localhost:3000/sample/oauth/callback2'
  s.scopes = 'public admin_users uid email name profile contact delivary_address openid'
  s.enable_client_credential_flow = true
end
