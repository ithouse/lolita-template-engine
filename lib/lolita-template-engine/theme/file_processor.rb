module Lolita
  module TemplateEngine
    class Theme

      class FileProcessor
        attr_reader :results
        def initialize(path, pattern, options = {})
          @options = options 
          @path = path
          @pattern = pattern
          @results = []
        end

        def process
          file = nil
          results.clear
          begin
            file = File.open(@path)
            process_file(file)
          ensure
            file.close if file
          end
        end

        private 

        def process_file(file)
          file.each do |line|
            if line.match(/data-#{@pattern}/)
              if process_line(line) && @options[:singular]
                return true
              end
            end
          end
        end

        def process_line(line)
          temp_results = {}
          regexps.each do |key,regexp|
            match_data = line.match(regexp)
            if match_data && match_data[1]
              temp_results[key] = match_data[1]
            end
          end
          if temp_results.any?
            results << temp_results 
            true
          else
            false
          end
        end

        def regexps
          @regexps ||= {
            :name => default_regexp(@pattern),
            :width => default_regexp("width"),
            :height => default_regexp("height"),
          }.merge(custom_regexps)
        end

        def custom_regexps
          temp_results = {}
          (@options[:custom_keys] || []).each do |key|
            temp_results[key] = default_regexp(key)
          end
          temp_results
        end

        def default_regexp(name)
          /data-#{name}\s*"?\s*=\s*"([^"]+)"/
        end

      end

    end
  end
end