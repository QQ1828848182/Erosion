<div align="center">
  <br>
  <a href="https://jailbreak.party/discord"><img src="https://github.com/jailbreakdotparty/Erosion/blob/main/PreviewIcon.png?raw=true" alt="App Icon" width="150"></a>
  <br>
  <h1>Erosion</h1>
  <p>基于 <a href="https://github.com/forcequitOS/worse_query">worse_query</a> 沙盒逃逸的 iOS 定制工具箱。</p>
  <p>支持 iOS 26.0 - 26.7.2 与 iOS 27.0 - 27.2。</p>
  <a href="https://github.com/jailbreakdotparty/Erosion/releases/latest"><img alt="GitHub Downloads (all assets, all releases)" src="https://img.shields.io/github/downloads/jailbreakdotparty/Erosion/total?style=flat-square&color=CF7D46"></a>
  <a href="https://github.com/jailbreakdotparty/Erosion/stargazers"> <img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/jailbreakdotparty/erosion?style=flat-square&color=%23FFD300"></a>
  <a href="https://jailbreak.party/discord"><img alt="Discord" src="https://img.shields.io/discord/1349128546072793218?style=flat-square&logo=discord&logoColor=FFFFFF&color=5865F2"></a>
  <a href="https://jailbreak.party"><img alt="Static Badge" src="https://img.shields.io/badge/jailbreak.party-blue?style=flat-square&label=%20&color=3868DB"></a>
</div>

> 本文件为 `README.md` 的简体中文译本，内容相同，如有差异以英文原版为准。

### 开始之前…
- 使用前请先备份你的设备！虽然 Erosion 经过了大量测试，但使用本工具仍存在丢失数据的可能。
- 如果某个修改无法按你的预期工作，**请不要提交 issue，也不要就其寻求支持！** 所有修改都依赖于你的设备正常配合，某些情况下甚至需要依赖 Apple 的服务器。我们无法为你提供帮助。

### 支持的版本
>[!NOTE]
>如果你的版本不在下表中，说明你的设备不受支持。**请不要就扩展版本支持向我们寻求任何帮助！** 这类应用所依赖的漏洞极其罕见，如果你的设备不受支持，我们也无能为力。
- iOS/iPadOS 26.0 - 26.6.2 **（功能受限，例如无法使用 gestalt 修改）**
- iOS/iPadOS 27.0 - 27.2
- iOS/iPadOS 27.3 beta 1 (24C5037i)

截至撰写本文时（2026-11-08），Apple 尚未在任何一个新系统版本中修复 worse_query，因此它在所有已发布的版本上均可使用。

预计这种情况在不久的将来会发生变化。

### 常见问题
1. **为什么我在 iOS 26 上无法使用 MobileGestalt 修改？** Erosion 所依赖的 `worse_query` 漏洞在 iOS 26 上*无法*写入 MobileGestalt，因此这些修改不起作用。
2. **为什么 PosterBoard 壁纸不显示？** 有时你需要重置 Collections，这可以在应用内完成。如果重置后壁纸仍不显示，那多半是壁纸本身的问题，而非 Erosion 能解决的。
3. **在哪里可以获取拨号键盘主题和自定义壁纸？** 请访问 https://cowabun.ga/wallpapers 。
4. **为什么打开「自定义壁纸」或「拨号键盘美化」时应用会卡住？** 首次打开这些修改时，Erosion 会自动检测应用容器路径。遗憾的是，目前使用的检测方法慢得让人抓狂。它应该会在约 30 秒内完成，而且这项设置只需执行一次。

### 致谢
- [lunginspector](https://github.com/lunginspector) - 主要开发者与维护者。
- [forcequit](https://github.com/forcequitOS) 与 [0xjohnny](https://github.com/0xjohnnydev) - worse_query 沙盒逃逸。
- [Skadz](https://github.com/skadz108) - 漏洞实现、后端功能与项目维护者。
- [rooootdev](https://github.com/rooootdev) - 各类后端组件。
- [neonmodder123](https://github.com/neonmodder123) - 开发了 WebView respring 方法。
