require 'fileutils'
require 'swagger2objc/generator/type'
require 'swagger2objc/config'
module Swagger2objc
  module Generator
    class FileGenerator
      def self.clear
        result_dir = Dir.pwd + Swagger2objc::Configure.output
        FileUtils.rm_rf(result_dir) if File.directory?(result_dir)
      end

      def self.copy_dir
        template_dir = Dir.pwd + '/template/'
        result_dir = Dir.pwd + Swagger2objc::Configure.output
        FileUtils.rm_rf(result_dir) if File.directory?(result_dir)
        # # copy template to result
        FileUtils.cp_r template_dir, result_dir
        result_dir
      end

      def self.copy_template_file(source_file, target_dir)
        template_dir = File.dirname(__FILE__) + '/template/'
        result_dir = Dir.pwd + Swagger2objc::Configure.output + target_dir + '/'
        FileUtils.mkdir_p(result_dir) unless File.directory?(result_dir)
        FileUtils.cp(template_dir + source_file, result_dir + source_file)
        result_dir + source_file
      end

      def self.copy_class_files(path)
        file_path_array = []
        h_file = '{class_name}.h'
        m_file = '{class_name}.m'
        file_path_array << copy_template_file(h_file, path)
        file_path_array << copy_template_file(m_file, path)
        file_path_array
      end

      def self.copy_plist_file(_path)
        template_dir = Dir.pwd + '/template/'
        result_dir = Dir.pwd + Swagger2objc::Configure.output
        plist = 'Interface.plist'
        FileUtils.mkdir_p(result_dir) unless File.directory?(result_dir)
        FileUtils.cp(template_dir + plist, result_dir + plist)
        result_dir + plist
      end

      def self.remove_template
        result_dir = Dir.pwd + Swagger2objc::Configure.output
        h_file = result_dir + '{class_name}.h'
        m_file = result_dir + '{class_name}.m'
        FileUtils.remove(h_file)
        FileUtils.remove(m_file)
      end
    end
  end
end
