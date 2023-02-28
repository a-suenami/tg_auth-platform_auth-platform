Redis.new(url: Settings.redis.url, db: 0).ping if defined? Rails::Server

class Redis
  class SomeConnection
    def multi(&block)
      Redis.pool.with do |redis|
        redis.multi do |pipeline|
          block.call(pipeline)
        end
      end
    end

    def method_missing(name, *args) # rubocop:disable Style/MissingRespondToMissing
      Redis.pool.with do |redis|
        redis.send(name, *args)
      end
    end
  end

  def self.pool
    return @pool if @pool

    size = ENV.fetch('RAILS_MAX_THREADS', 10).to_i

    @pool = ConnectionPool.new(size: size * 3, timeout: 5) do
      Redis.new(url: Settings.redis.url, db: 0)
    end
  end

  # Connection pool のいずれかの connection に対してコマンドの実行をさせる method
  def self.some
    SomeConnection.new
  end
end
