# typed: false

module ChangeNotifications
  class SendService < ::BaseService
    def execute(user:, action_code:)
      sqs_client = Aws::SQS::Client.new(access_key_id: Settings.aws.access_key_id, secret_access_key: Settings.aws.secret_access_key, region: Settings.aws.region)
      message_body = {
        tenant_id: user.tenant_id,
        user_id: user.id,
        action_code: action_code,
        submitted_at: Time.zone.now.to_s
      }.to_json
      sqs_client.send_message(
        queue_url: Settings.aws_sqs.queue_url,
        message_body: message_body
      )
    end
  end
end
