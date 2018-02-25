# Augment the main migration to migrate your engine, too.
task 'db:migrate', 'sqlbox:db:migrate'

# Augment to dump/load the engine schema, too
task 'db:schema:dump', 'sqlbox:db:schema:dump'
task 'db:schema:load', 'sqlbox:db:schema:load'

namespace :sqlbox do
  namespace :db do
    desc 'Migrates the sqlbox database'
    task :migrate => :environment do
      p "sqlbox db migrate"
      with_engine_connection do
        ActiveRecord::Migrator.migrate("#{File.dirname(__FILE__)}/../../db/sqlbox/migrate", ENV['VERSION'].try(:to_i))
      end
      Rake::Task['sqlbox:db:schema:dump'].invoke
    end

    task :'schema:dump' => :environment do
      require 'active_record/schema_dumper'

      with_engine_connection do
        File.open(File.expand_path('../../../db/sqlbox/schema.rb', __FILE__), 'w') do |file|
          ActiveRecord::SchemaDumper.dump ActiveRecord::Base.connection, file
        end
      end
    end

    task :'schema:load' => :environment do
      with_engine_connection do
        load File.expand_path('../../../db/sqlbox/schema.rb', __FILE__)
      end
    end
  end
end

# Hack to temporarily connect AR::Base to sqlbox.
def with_engine_connection
  original = ActiveRecord::Base.remove_connection
  # ActiveRecord::Base.establish_connection "sqlbox_#{Rails.env}".to_sym
  ActiveRecord::Base.establish_connection 'sqlbox'.to_sym
  yield
ensure
  ActiveRecord::Base.establish_connection original
end