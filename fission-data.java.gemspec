if(RUBY_ENGINE == 'java')
  eval File.read(File.expand_path(File.join(File.dirname(__FILE__), 'fission-data.gemspec')))
  spec.platform = 'java'
  spec.dependencies.delete_if do |dep|
    dep.name == 'pg'
  end
  spec.add_dependency 'jdbc-postgres'
  spec
end
