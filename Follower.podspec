Pod::Spec.new do |s|

  s.name         = "Follower"
  s.version      = "0.1"
  s.summary      = "Track trip distance, speed, altitude, and duration like a boss."
  s.homepage     = "https://github.com/mamaral/Follower"
  s.license      = "MIT"
  s.author       = { "Mike Amaral" => "mike.amaral36@gmail.com" }
  s.social_media_url   = "http://twitter.com/MikeAmaral"
  s.platform     = :ios
  s.source       = { :git => "https://github.com/mamaral/Follower.git", :tag => "v0.1" }
  s.source_files  = "Source/Objective-C/Follower.{h,m}"
  s.requires_arc = true

end
