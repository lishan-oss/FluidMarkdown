Pod::Spec.new do |s|

  s.name             = 'AntMarkdown'
  s.version          = '0.1.2'
  s.summary          = 'Markdown + LaTeX renderer for iOS'

  s.description      = <<-DESC
Markdown renderer with:
- Markdown
- GFM
- Code Highlight
- LaTeX
- Streaming Render
DESC

  s.homepage         = 'https://github.com/shengjunxiangban/FluidMarkdown'

  s.license          = {
      :type => 'Apache-2.0',
      :file => 'LICENSE'
  }

  s.author           = {
      'Li Shan' => 'xxx@qq.com'
  }

  s.platform         = :ios, '11.0'
  s.requires_arc     = true

  s.source           = {
      :git => 'https://github.com/shengjunxiangban/FluidMarkdown.git',
      :tag => s.version.to_s
  }

  # ── 所有源文件：External 依赖 + Public 核心 + 上层 Widget 层 ──
  s.source_files = [
      'AntMarkdown/Sources/**/*.{h,m,c,inc,swift}'
  ]

  # ── 对外暴露的头文件（消费者 #import 时必须能找到的所有头） ──
  s.public_header_files = [
      # 核心 AntMarkdown 公开 API
      'AntMarkdown/Sources/Public/**/*.h',

      # CocoaMarkdown 头文件（公开头文件中直接 #import，消费者需要能找到）
      'AntMarkdown/Sources/External/CocoaMarkdown/*.h',

      # Ono 头文件（AntMarkdown.h 及 CocoaMarkdown 内部 import）
      'AntMarkdown/Sources/External/Ono/*.h',

      # cmark-gfm 头文件（CMNode.h / CMDocument.h 中 #include，消费者传递依赖）
      'AntMarkdown/Sources/External/cmark-gfm/*.h',
      'AntMarkdown/Sources/External/cmark-gfm/src/*.h',
      'AntMarkdown/Sources/External/cmark-gfm/extensions/*.h',

      # iosMath 头文件（AMBlockMathAttachment.h 等公开头使用 MTMathListDisplay
      # 等类型，消费者调用相关接口时需要可见）
      'AntMarkdown/Sources/External/iosMath/*.h',
      'AntMarkdown/Sources/External/iosMath/lib/*.h',
      'AntMarkdown/Sources/External/iosMath/render/*.h',
      'AntMarkdown/Sources/External/iosMath/render/internal/*.h',

      # Widget 层上层 API
      'AntMarkdown/Sources/API/**/*.h',
      'AntMarkdown/Sources/Markdown/**/*.h',
      'AntMarkdown/Sources/Style/**/*.h',
      'AntMarkdown/Sources/Util/**/*.h'
  ]

  # 注意：exclude_files 会双向作用于 source_files 和 resource_bundles，
  # 所以不能用 '**/*.plist' 这种大范围通配，否则会误伤
  # mathFonts.bundle/xits-math.plist（iosMath 数学字体 MATH 表，必需）。
  s.exclude_files = [
      'AntMarkdown/Sources/External/CocoaMarkdown/Info.plist',
      '**/CMakeLists.txt'
  ]

  s.resource_bundles = {
      'AntMarkdown' => [
          # 包含 PrivacyInfo.xcprivacy、AntMarkdown.bundle/、highlightjs.bundle/、mathFonts.bundle/ 下所有资源。
          # PrivacyInfo.xcprivacy 位于 Resources/ 根目录，会被平铺到 AntMarkdown.bundle/PrivacyInfo.xcprivacy，
          # CocoaPods 1.15+ 在 use_frameworks! 模式下会自动同步到 framework 根目录，满足 App Store 打包要求。
          'AntMarkdown/Resources/**/*'
      ]
  }

  s.frameworks = %w[
      UIKit
      Foundation
      CoreText
      CoreGraphics
      JavaScriptCore
  ]

  s.libraries = 'c++'

  s.pod_target_xcconfig = {

      'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++17',

      # pod 目标编译时的头文件搜索路径（非递归，需逐层列出）
      'HEADER_SEARCH_PATHS' => [
          '$(inherited)',
          # Public / External 核心层
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/Public',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/CocoaMarkdown',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/Ono',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/cmark-gfm',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/cmark-gfm/src',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/cmark-gfm/extensions',
          # iosMath（已加入 public_header_files；仍需逐层列出供 pod 自身编译）
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/iosMath',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/iosMath/lib',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/iosMath/render',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/External/iosMath/render/internal',
          # Widget 上层（Markdown / Style / Util 各自为独立目录，需逐个列出）
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/Markdown',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/Style',
          '$(PODS_TARGET_SRCROOT)/AntMarkdown/Sources/Util',
      ].join(' ')
  }

end
