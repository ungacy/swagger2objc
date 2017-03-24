require 'fileutils'
require 'swagger2objc/generator/type'
require 'swagger2objc/config'

module Swagger2objc
  module Generator
    class FileGenerator
      def self.clear(type)
        result_dir = Dir.pwd + Swagger2objc::Configure.output(type)
        FileUtils.rm_rf(result_dir) if File.directory?(result_dir)
      end

      def self.copy_dir(type)
        template_dir = Dir.pwd + '/template/' + type
        result_dir = Dir.pwd + Swagger2objc::Configure.output(type)
        FileUtils.rm_rf(result_dir) if File.directory?(result_dir)
        # # copy template to result
        FileUtils.cp_r template_dir, result_dir
        result_dir
      end

      def self.copy_template_file(source_file, target_dir, type)
        template_dir = File.dirname(__FILE__) + '/template/' + type + '/'
        result_dir = Dir.pwd + Swagger2objc::Configure.output(type) + target_dir + '/'
        FileUtils.mkdir_p(result_dir) unless File.directory?(result_dir)
        FileUtils.cp(template_dir + source_file, result_dir + source_file)
        result_dir + source_file
      end

      def self.copy_class_files(path, type)
        file_path_array = []
        h_file = '{class_name}.h'
        m_file = '{class_name}.m'
        file_path_array << copy_template_file(h_file, path, type)
        file_path_array << copy_template_file(m_file, path, type)
        file_path_array
      end

      def self.copy_module_header_files(category, type)
        template_dir = File.dirname(__FILE__) + '/template/' + type + '/'
        result_dir = Dir.pwd + Swagger2objc::Configure.output(type) + '/' + category + '/'
        header = '{module_name}.h'
        FileUtils.mkdir_p(result_dir) unless File.directory?(result_dir)
        FileUtils.cp(template_dir + header, result_dir + header)
        result_dir + header
      end

      def self.copy_plist_file(type)
        template_dir = File.dirname(__FILE__) + '/template/' + type + '/'
        result_dir = Dir.pwd + Swagger2objc::Configure.output(type)
        plist = 'Interface.plist'
        FileUtils.mkdir_p(result_dir) unless File.directory?(result_dir)
        FileUtils.cp(template_dir + plist, result_dir + plist)
        result_dir + plist
      end

      def self.remove_template
        result_dir = Dir.pwd + Swagger2objc::Configure.output(type)
        h_file = result_dir + '{class_name}.h'
        m_file = result_dir + '{class_name}.m'
        FileUtils.remove(h_file)
        FileUtils.remove(m_file)
      end
    end
  end
end
