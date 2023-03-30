# seed oauth applications
Doorkeeper::Application.seed do |s|
  s.id = '40ce3073-75a6-4c47-8ebd-6a4fde3f81be'
  s.uid = '7s29N_Ro1IjSp50dtjLyB15u026Zk7G24pCz0Oy70XI'
  s.secret = 'leV04prfWVBOgfmALi2wtls8ACecpw09TUGXyrAAEIs'
  s.tenant_id = 'sample'
  s.name = 'Sample Application'
  s.redirect_uri = 'http://localhost:3000/oauth/callback'
end
