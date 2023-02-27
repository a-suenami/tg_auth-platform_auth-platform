# ==============================================================================
# lib - tasks - ridgepole
# ==============================================================================
namespace :ridgepole do # rubocop:disable Metrics/BlockLength
  desc 'Apply database schema'
  task apply: :environment do
    check_non_required_schemas if Rails.env.development?

    ridgepole('--apply', "--file #{schema_file}")

    if Rails.env.development?
      print "\n"
      puts 'Re-creating test database...'
      suppress_output do
        # test の DB を利用する
        Rails.env = 'test'

        Rake::Task['db:drop'].invoke
        Rake::Task['db:create'].invoke

        ridgepole('--apply', "--file #{schema_file}", '--env test')

        # schema.rb と structure.sql の両方吐かせる
        ActiveRecord::Base.schema_format = :ruby
        Rake::Task['db:schema:dump'].invoke
        ActiveRecord::Base.schema_format = :sql
        Rake::Task['db:schema:dump'].invoke
      end
      puts 'done'
    end
  end

  task dry: :environment do
    ridgepole('--apply', '--dry-run --verbose', "--file #{schema_file}")
  end

  desc 'Export database schema'
  task export: :environment do
    ridgepole('--export --split', "--output #{schema_file}")
  end

  private

  def schema_file
    Rails.root.join('db/Schemafile')
  end

  def config_file
    if ENV['DATABASE_URL'].present?
      uri = URI.parse(ENV.fetch('DATABASE_URL', nil))

      if [uri.scheme, uri.user, uri.password, uri.host, uri.path].any?(&:nil?)
        raise "Invalid uri: #{uri}"
      end

      # for fuckin' heroku uri scheme
      uri.scheme = 'postgresql' if uri.scheme == 'postgres'

      "\'{
        adapter:  #{uri.scheme},
        username: #{uri.user},
        password: #{uri.password},
        host:     #{uri.host},
        database: #{uri.path.sub(%r{\A/}, '')},
      }\'"

    else
      Rails.root.join('config/database.yml')
    end
  end

  def check_non_required_schemas
    schema_file_content = File.read(schema_file)
    requirements = schema_file_content.scan(%r{require 'schemas/.*$}).map { _1.match(/(schemas.*)'/)[1] }
    schema_files = Dir.glob(Rails.root.join('db/schemas/**/*.schema')).map { _1.match(/(schemas.*)/)[1] }

    diff = schema_files - requirements

    puts("\033[33mWarning:\033[m There are unapplied schemas:")
    puts(diff.join("\n"))
  end

  def ridgepole(*options)
    command = ['bundle exec ridgepole', "--config #{config_file}", '--dump-with-default-fk-name']
    system([command + options].join(' '), exception: true)
  end

  def suppress_output
    original_stdout = $stdout.clone
    original_stderr = $stderr.clone
    $stdout.reopen File.new('/dev/null', 'w')
    $stderr.reopen File.new('/dev/null', 'w')
    yield
  ensure
    $stdout.reopen original_stdout
    $stderr.reopen original_stderr
  end
end
