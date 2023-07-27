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


EmailTemplate.seed do |s|
  s.id = '55df5301-4f0e-4151-9c31-ce92c88cdec7'
  s.tenant_id = 'sample'
  s.name = 'password reset メールテンプレート'
  s.template_type = 'password_reset'
  s.subject = 'password reset メール！'
  s.body = <<~TEXT
    <p>以下のURLを開いてパスワードを設定してください</p>
    <p>{{ password_reset_url }}</p>
  TEXT
end

EmailTemplate.seed do |s|
  s.id = 'e3103a60-be8c-407a-a0c4-85b958467981'
  s.tenant_id = 'sample'
  s.name = 'email変更 code メールテンプレート'
  s.template_type = 'email_address_change'
  s.subject = 'email変更 code メール'
  s.body = <<~TEXT
    <p>email変更を完了するため、以下のコードを入力してください</p>
    <p>{{ email_verification_code }}</p>
  TEXT
end

EmailTemplate.seed do |s|
  s.id = '9466a31e-e2d4-4daf-8f36-32616abe1e68'
  s.tenant_id = 'sample'
  s.name = 'アカウントロック メールテンプレート'
  s.template_type = 'account_lock'
  s.subject = 'アカウントロック メール'
  s.body = <<~TEXT
    <p>アカウントロックを解除するには以下のリンクをクリックしてください</p>
    <p>{{ unlock_url }}</p>
  TEXT
end

