module Merb::Cache
  class FileStore < AbstractStore
    attr_accessor :dir

    def initialize(config = {})
      @dir = config[:dir] || Merb.root_path(:tmp / :cache)

      create_path(@dir)
    end

    def writable?(key, parameters = {}, conditions = {})
      case key
      when String, Numeric, Symbol
        !conditions.has_key?(:expire_in)
      else nil
      end
    end

    def read(key, parameters = {})
      if exists?(key, parameters)
        read_file(pathify(key, parameters))
      end
    end

    def write(key, data = nil, parameters = {}, conditions = {})
      if writable?(key, parameters, conditions)
        if File.file?(path = pathify(key, parameters))
          write_file(path, data)
        else
          create_path(path) && write_file(path, data)
        end
      end
    end

    def fetch(key, parameters = {}, conditions = {}, &blk)
      read(key, parameters) || (writable?(key, parameters, conditions) && write(key, blk.call, parameters, conditions))
    end

    def exists?(key, parameters = {})
      File.file?(pathify(key, parameters))
    end

    def delete(key, parameters = {})
      if File.file?(path = pathify(key, parameters))
        FileUtils.rm(path)
      end
    end

    def delete_all
      raise NotSupportedError
    end

    def create_path(path)
      FileUtils.mkdir_p(File.dirname(path))
    end

    def read_file(path)
      data = nil
      File.open(path, "r") do |file|
        file.flock(File::LOCK_EX)
        data = file.read
        file.flock(File::LOCK_UN)
      end

      data
    end

    def write_file(path, data)
      File.open(path, "w+") do |file|
        file.flock(File::LOCK_EX)
        file.write(data)
        file.flock(File::LOCK_UN)
      end

      true
    end

    def pathify(key, parameters = {})
      if key.to_s =~ /^\//
        path = "#{@dir}#{key}"
      else
        path = "#{@dir}/#{key}"
      end

      path << "--#{parameters.to_sha2}" unless parameters.empty?
      path
    end
  end
end