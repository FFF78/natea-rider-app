# NaTea 配送员 App

这个 App 是一个「外壳」：打开后显示网站上的配送页（`rider.php`），所以**以后改配送页功能，只改网站，不用重新发 App**。
App 额外加了一样网页做不到的东西：**后台定位**——送单时切到别的 App、锁屏，位置也会继续上报。

> 网站这边要先把新的 `rider.php` 传上去（它会自动识别是不是在 App 里，在 App 里就用后台定位，在浏览器里还是原来的网页定位）。

## 准备
- 电脑装好 **Node.js 20+**（https://nodejs.org）
- 做 Android：装 **Android Studio**（https://developer.android.com/studio）
- 做 iPhone：要一台 **Mac**，装 **Xcode**，还要付费的 **Apple Developer 账号**（99 美元/年）
- 网址不是现在这个的话，改 `capacitor.config.json` 里的 `server.url` 和 `allowNavigation`

## 第一步：生成工程（Android + iPhone 一起）
```
cd natea-rider-app
bash setup.sh
```
它会安装依赖、生成 `android/`（Mac 上还有 `ios/`）、自动补好定位权限。出错把提示发给我。

## Android：出安装包（APK）
1. `npx cap open android`（Android Studio 打开，等它 Gradle 同步完）
2. 菜单 **Build → Build Bundle(s) / APK(s) → Build APK(s)**
3. 完成后点右下角 **locate**，得到 `app-debug.apk`，发给配送员，点开安装（要允许「安装未知来源应用」）
4. 正式长期用建议 **Build → Generate Signed Bundle / APK** 做一个签名版本（同一把密钥以后更新才能覆盖安装，**密钥文件要备份好**）
5. 配送员第一次点「出发」时选 **「始终允许」定位**；再去 手机设置 → 应用 → NaTea 配送 → 电池，选 **不限制**（小米 / OPPO / vivo / 三星尤其要）

## iPhone：TestFlight
1. `npx cap open ios`（Xcode 打开）
2. 左边选 **App** → Signing & Capabilities → 选你的 **Team**；Bundle Identifier 如果提示被占用，改成 `com.你的名字.natea.rider`
3. 同一页确认有 **Background Modes → Location updates**（没有就点 + Capability 添加）
4. 顶部设备选 **Any iOS Device (arm64)** → 菜单 **Product → Archive**
5. 打包完在 Organizer 点 **Distribute App → App Store Connect → Upload**
6. 去 https://appstoreconnect.apple.com → 我的 App → 新建 App（名称 NaTea 配送，Bundle ID 同上）
7. 进 **TestFlight** → 等构建处理完（约 10–30 分钟）→ 内部测试 / 外部测试 → 添加配送员的邮箱（内部测试最多 100 人，不用审核；外部测试第一次要苹果简单审核）
8. 配送员手机装 **TestFlight** App，点邀请邮件 / 链接安装
9. 第一次点「出发」选 **「始终」** 定位

## 每 80 天续期（TestFlight 版本 90 天过期）
Xcode 里把 **Version/Build** 的 Build 号加 1 → Archive → Upload。配送员手机的 TestFlight 会提示更新。Android 不用。

## 常见问题
- **App 里是空白 / 连不上**：看手机能不能打开网站；`server.url` 是不是 https 且网址正确。
- **位置不上报**：确认选了「始终允许」；送单点了「出发」才会开始上报；安卓要设电池不限制。
- **改了 `capacitor.config.json`**：重新运行 `npx cap sync`。
- 图标：默认是 Capacitor 图标。想换，放一张 1024×1024 的 `assets/icon.png`，运行 `npx @capacitor/assets generate`。
