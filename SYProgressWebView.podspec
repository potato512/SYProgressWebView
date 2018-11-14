Pod::Spec.new do |s|
  s.name         = "SYProgressWebView"
  s.version      = "1.0.0"
  s.summary      = "SYProgressWebView will show progress while loading web."
  s.homepage     = "https://github.com/potato512/SYProgressWebView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "herman" => "zhangsy757@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/potato512/SYProgressWebView.git", :tag => "#{s.version}" }
  s.source_files  = "SYProgressWebView/**/*.{h,m}"
  s.framework    = "UIKit"
  s.requires_arc = true
end
