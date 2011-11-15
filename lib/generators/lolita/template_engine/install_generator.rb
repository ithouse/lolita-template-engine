module Lolita
  module TemplateEngine
    module Generators
      class InstallGenerator < Rails::Generators::Base
        include Rails::Generators::Migration

        source_root File.expand_path("../templates", __FILE__)
        desc "Create migrations. "

        @@migration_counts = 0

        def self.next_migration_number(dirname)
          @@migration_counts +=1
          if ActiveRecord::Base.timestamped_migrations
            base_time = (Time.now.utc.strftime("%Y%m%d%H%M")+"00").to_i
            base_time + @@migration_counts
          else
            "%.3d" % (current_migration_number(dirname) + @@migration_counts)
          end
       end

       def generate_migrations
          begin
            migration_template "migrations/create_layout.rb", "db/migrate/create_lolita_layout.rb"
            migration_template "migrations/create_content_block.rb", "db/migrate/create_lolita_content_block.rb" 
            migration_template "migrations/create_layout_configuration.rb", "db/migrate/create_lolita_layout_configuration.rb"
            migration_template "migrations/create_layout_url.rb", "db/migrate/create_lolita_layout_url.rb"
          rescue Exception => e
            puts e
          end
        end

      end
    end
  end
end