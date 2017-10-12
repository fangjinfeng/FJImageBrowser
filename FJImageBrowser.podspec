Pod::Spec.new do |s|
  s.name         = "FJImageBrowser"
  s.version      = "1.0.0"
  s.summary      = "图片浏览器 :支持上下拖动、横竖屏旋转、进行内存优化、支持加载过程先居中，加载完成后放大和直接放大两种效果"
  s.homepage     = "http://www.jianshu.com/p/bea2bfed3f3f"
 s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'fangjinfeng' => '116418179@qq.com' }
  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/fangjinfeng/FJImageBrowser.git", :tag => "0.0.1" }
  s.source_files = 'FJImageBrowser/**/*.{h,m}'
   s.resources    = "FJImageBrowser/Resourse/*.{png}"
  s.requires_arc = true
  s.framework  = 'UIKit'
  s.dependency "SDWebImage", "~> 4.1.0"
end
