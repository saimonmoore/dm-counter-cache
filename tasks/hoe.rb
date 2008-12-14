hoe = Hoe.new(GEM_NAME, GEM_VERSION) do |p|
 
  p.developer(AUTHOR, EMAIL)
 
  p.description = PROJECT_DESCRIPTION
  p.summary = PROJECT_SUMMARY
  p.url = PROJECT_URL
 
  p.rubyforge_name = PROJECT_NAME if PROJECT_NAME
 
  p.clean_globs |= GEM_CLEAN
  p.spec_extras = GEM_EXTRAS if GEM_EXTRAS
 
  GEM_DEPENDENCIES.each do |dep|
    p.extra_deps << dep
  end
 
end