Pod::Spec.new do |s|
  s.name = "OMGHTTPURLRQ"
  s.version = "1.1.4"
  s.homepage = "https://github.com/mxcl/#{s.name}"
  s.source = { :git => "https://github.com/mxcl/#{s.name}.git", :tag => s.version }
  s.license = { :type => 'No License', :text => 'This text or CocoaPods throws a fit' }
  s.summary = 'Vital extensions to NSURLRequest that Apple left out for some reason.'

  s.social_media_url = 'https://twitter.com/mxcl'
  s.authors  = { 'Max Howell' => 'mxcl@me.com' }

  s.requires_arc = true

  s.ios.deployment_target = '5.0'
  s.osx.deployment_target = '10.7'

  s.subspec 'RQ' do |ss|
    s.source_files = 'OMGHTTPURLRQ.{h,m}'
    s.dependency 'ChuzzleKit'
    s.dependency 'OMGHTTPURLRQ/UserAgent'
  end

  s.subspec 'UserAgent' do |ss|
    ss.source_files = 'OMGUserAgent.{h,m}'
  end
end
