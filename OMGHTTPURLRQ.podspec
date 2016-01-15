Pod::Spec.new do |s|
  s.name = "OMGHTTPURLRQ"

  `xcodebuild -project #{s.name}.xcodeproj -showBuildSettings` =~ /CURRENT_PROJECT_VERSION = ((\d\.)+\d)/
  abort if $1.nil?
  s.version = $1
  
  s.homepage = "https://github.com/mxcl/#{s.name}"
  s.source = { :git => "https://github.com/mxcl/#{s.name}.git", :tag => s.version }
  s.license = { :type => 'MIT', :text => 'See README.markdown for full license text.' }
  s.summary = 'Vital extensions to NSURLRequest that Apple left out for some reason (including creating multipart/form-data POSTs)'

  s.social_media_url = 'https://twitter.com/mxcl'
  s.authors  = { 'Max Howell' => 'mxcl@me.com' }

  s.requires_arc = true

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'

  s.default_subspecs = 'RQ'

  s.subspec 'RQ' do |ss|
    ss.source_files = 'Sources/OMGHTTPURLRQ.swift'
    ss.dependency 'OMGHTTPURLRQ/UserAgent'
    ss.dependency 'OMGHTTPURLRQ/FormURLEncode'
  end

  s.subspec 'UserAgent' do |ss|
    ss.source_files = 'Sources/OMGUserAgent.swift'
  end

  s.subspec 'FormURLEncode' do |ss|
    ss.source_files = 'Sources/OMGFormURLEncode.swift'
  end

end
