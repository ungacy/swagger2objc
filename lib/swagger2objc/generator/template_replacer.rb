require 'swagger2objc/generator/file_generator'
require 'set'

module Swagger2objc
  module Generator
    class TemplateReplacer
      @@generated_set = Set.new

      def self.read_file_content(file_path)
        file = File.open(file_path, 'rb')
        contents = file.read
        file.close
        contents
      end

      def self.replace(replacement, type)
        # path length = 0时是返回.不重生成
        category = replacement[:category]
        service = replacement[:service]
        service = service.sub('/api', '')
        service = if service.start_with?('/')
                    service[0] + service[1].upcase + service[2..-1]
                  else
                    service[0].upcase + service[1..-1]
                  end

        class_name = replacement[:class_name]
        puts "\033[31m #{class_name} \033[0m" if @@generated_set.include?(class_name) && class_name.start_with?('SRK')
        return if @@generated_set.include?(class_name)
        @@generated_set << class_name
        file_path_array = FileGenerator.copy_class_files(service + '/' + category, type)
        file_path_array = replace_file_array_name(file_path_array, '{class_name}', class_name)
        replacement.each do |key, value|
          replace_file_array_content(file_path_array, "{#{key}}", value)
        end
        time = Time.now
        year = time.year.to_s # + '年'
        # date = time.strftime('%Y/%m/%d')
        replace_file_array_content(file_path_array, '{year}', year)
        # replace_file_array_content(file_path_array, '{date}', date)

        # set_file_array_read_only(file_path_array)
      end

      def self.replace_framework_header_content(replacement)
        file_path = FileGenerator.copy_sdk_header_file
        result = ''
        replacement.lines.each do |line|
          result += "#import \"#{line.sub("\n", '')}.h\"" + "\n"
        end
        replace_file_content(file_path, "\n#endif", result + "\n#endif")
      end

      def self.replace_module_header_content(replacement)
        category = replacement[:category]
        service = replacement[:service]
        service = service.sub('/api', '')
        service = if service.start_with?('/')
                    service[0] + service[1].upcase + service[2..-1]
                  else
                    service[0].upcase + service[1..-1]
                  end

        if service == '/Web' && category == 'Material'
          replacement[:module_name] = 'SRKWebMaterial'
        end
        if service == '/Web' && category == 'Notice'
          replacement[:module_name] = 'SRKWebNotice'
        end
        module_name = replacement[:module_name]
        file_path = FileGenerator.copy_module_header_files(service + '/' + category, Swagger2objc::Config::SDK)
        replacement.each do |key, value|
          replace_file_content(file_path, "{#{key}}", value)
        end
        time = Time.now
        year = time.year.to_s # + '年'
        # date = time.strftime('%Y/%m/%d')
        replace_file_content(file_path, '{year}', year)
        # replace_file_content(file_path, '{date}', date)
        replace_file_name(file_path, '{module_name}', module_name)
        module_name
      end

      def self.replace_dir(dir, target, replacement)
        Dir.foreach(dir) do |entry|
          if !entry[0..1].include?('.') && !File.directory?(entry)
            newfilename = entry.sub(target, replacement)
            File.rename(dir + entry, dir + newfilename)
            File.open(dir + newfilename) do |fr|
              buffer = fr.read.gsub(target, replacement)
              File.open(dir + newfilename, 'w') { |fw| fw.write(buffer) }
            end
          end
        end
      end

      def self.replace_file_array(file_path_array, target, replacement)
        file_path_array.each do |file_path|
          replace_file(file_path, target, replacement)
        end
      end

      def self.replace_file(file_path, target, replacement)
        if !file_path[0..1].include?('.') && !File.directory?(file_path)
          newfilename = file_path.sub(target, replacement)
          File.rename(file_path, newfilename)
          File.open(file_path) do |fr|
            buffer = fr.read.gsub(target, replacement)
            File.open(newfilename, 'w') { |fw| fw.write(buffer) }
          end
        end
      end

      def self.replace_file_array_name(file_path_array, target, replacement)
        new_file_path_array = []
        file_path_array.each do |file_path|
          new_file_path_array << replace_file_name(file_path, target, replacement)
        end
        new_file_path_array
      end

      def self.replace_file_name(file_path, target, replacement)
        puts 'nil tartget' if target.nil?
        puts 'nil replacement' if replacement.nil?
        newfilename = file_path.sub(target, replacement)

        begin
          File.rename(file_path, newfilename)
        rescue
          puts error
        end

        newfilename
      end

      def self.replace_file_array_content(file_path_array, target, replacement)
        file_path_array.each do |file_path|
          replace_file_content(file_path, target, replacement)
        end
      end

      def self.replace_plist_content(replacement)
        target = '{content}'
        file_path = FileGenerator.copy_plist_file(Swagger2objc::Config::SDK)
        replace_file_content(file_path, target, replacement)
      end

      def self.replace_file_content(file_path, target, replacement)
        File.open(file_path) do |fr|
          buffer = fr.read.gsub(target, replacement)
          File.open(file_path, 'w') { |fw| fw.write(buffer) }
        end
      end

      def self.set_file_array_read_only(file_path_array)
        file_path_array.each do |file_path|
          set_file_read_only(file_path)
        end
      end

      def self.set_file_read_only(file)
        FileUtils.chmod 'a-w', file
      end
    end
  end
end
