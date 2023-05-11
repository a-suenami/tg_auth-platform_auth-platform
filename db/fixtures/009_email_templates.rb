EmailTemplate.seed do |s|
  s.id = 'cd857392-b3ef-4776-944f-ec52cddac057'
  s.tenant_id = 'sample'
  s.name = '新規登録完了メールテンプレート'
  s.template_type = 'registration'
  s.subject = '新規登録完了メール！'
  s.body = <<~TEXT
    <p>この度は、サンプルアプリケーションへのご登録ありがとうございます。</p>
    <p>ご登録いただいたメールアドレスは、以下の通りです。</p>
    {{ email }}
  TEXT
end

EmailTemplate.seed do |s|
  s.id = '45df5301-4f0e-4151-9c31-ce92c88cdec7'
  s.tenant_id = 'sample'
  s.name = 'emailVerificationメールテンプレート'
  s.template_type = 'email_address_verification'
  s.subject = 'emailVerificationメール！'
  s.body = <<~TEXT
    <p>認証コードは以下です</p>
    <p>{{ email_verification_code }}</p>
  TEXT
end
