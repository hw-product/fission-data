module Fission
  module Data
    Dir.glob(File.join(File.dirname(__FILE__), File.basename(__FILE__).sub(File.extname(__FILE__), ''), '*')).map do |file|
      [File.basename(file).sub(File.extname(file), '').split('_').map(&:capitalize).join.to_sym, file.sub(File.extname(file), '')]
    end.uniq.each do |klass_info|
      autoload *klass_info
    end
  end
end
