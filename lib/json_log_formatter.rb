# typed: false

# https://qiita.com/minamijoyo/items/7237efa140013dd53870
# https://github.com/roidrage/lograge/issues/255
class JSONLogFormatter < Logger::Formatter
  def call(severity, time, progname, msg)
    log = {
      severity: severity.to_s,
      time: time.iso8601(6),
      level: severity.to_s,
      progname: progname.to_s,
      type: 'default',
    }

    # タグが付いてる場合
    if defined?(current_tags) && !current_tags.empty?
      # タグのkey=valueのmapを作ってマージ
      tagged = ::Rails.application.config.log_tags.zip(current_tags).to_h
      log.merge!(tagged)
      # msgの先頭に入ってるタグを削除
      msg = msg&.split(' ', current_tags.size + 1)&.last
      msg
    end
    begin
      # msgがJSON形式の場合は JSON in JSON をフラットにしてマージする
      parsed = ::JSON.parse(msg).symbolize_keys
      log.merge!(parsed)
    rescue ::JSON::ParserError
      # JSON形式ではない場合は、meessageというkeyに保存
      log.merge!({ message: msg })
    end

    "#{log.to_json}\n"
  end
end
