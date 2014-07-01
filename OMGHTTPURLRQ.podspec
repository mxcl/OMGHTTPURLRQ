Pod::Spec.new do |s|
  s.name = "OMGHTTPURLRQ"
  s.version = "1.1.2"
  s.homepage = "https://github.com/mxcl/#{s.name}"
  s.source = { :git => "https://github.com/mxcl/#{s.name}.git", :tag => s.version }
  s.license = 'MIT'
  s.summary = 'Vital extensions to NSURLRequest that Apple left out for some reason.'

  s.social_media_url = 'https://twitter.com/mxcl'
  s.authors  = { 'Max Howell' => 'mxcl@me.com' }

  s.requires_arc = true
  s.compiler_flags = '-fmodules'

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'
  
  s.dependency "ChuzzleKit"
  
  s.source_files = '*.{h,m}'
end
