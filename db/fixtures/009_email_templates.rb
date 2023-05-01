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
