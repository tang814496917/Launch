Pod::Spec.new do |s|
  s.name         = "CJLaunch"
  s.version      = "0.0.1"
  s.ios.deployment_target = '8.0'
  s.summary      = "简介"
  s.homepage     = "https://github.com/tang814496917/Launch.git"
  s.social_media_url = 'https://www.baidu.com'
  s.license      = "MIT"
  # s.license    = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author       = { "war_eve" => "814496917@qq.com" }
  s.source       = { :git => 'https://github.com/tang814496917/Launch.git', :tag => s.version}
  s.requires_arc = true
  s.source_files = 'Launch/*'
  #s.public_header_files = 'runtime/TFRuntimeManager.h'
 
end