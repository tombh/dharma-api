guard 'bundler' do
  watch('Gemfile')
end
 
guard 'rack', :force_run => true do
  watch('Gemfile.lock')
  watch(%r{^(app)/.*rb})
end