# AntMarkdown（CocoaPods）


Fork 自 [antgroup/FluidMarkdown](https://github.com/antgroup/FluidMarkdown)，便于通过 CocoaPods 集成。

## 发布到 GitHub（打 tag 后主工程即可 `pod install`）

```bash
git add -A
git commit -m "chore: AntMarkdown 0.1.1 podspec + LICENSE"
git push origin main
git tag 0.1.1
git push origin 0.1.1
```

主工程 `Podfile`：

```ruby
pod 'AntMarkdown', git: 'https://github.com/shengjunxiangban/FluidMarkdown.git', tag: '0.1.1'
```

## 本地联调（未 push tag 时）

```ruby
pod 'AntMarkdown', path: '../FluidMarkdown'
```

## 校验 podspec

```bash
pod spec lint AntMarkdown.podspec --quick --allow-warnings
```
