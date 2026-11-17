#!/usr/bin/env bash
# 一键生成 Android / iPhone 工程并补好权限。在本文件夹里运行：bash setup.sh
set -e
cd "$(dirname "$0")"
command -v node >/dev/null || { echo "请先安装 Node.js 20 或更新版本：https://nodejs.org"; exit 1; }
npm install

# ---------- Android ----------
if [ ! -d android ]; then npx cap add android; fi
M=android/app/src/main/AndroidManifest.xml
for P in ACCESS_COARSE_LOCATION ACCESS_FINE_LOCATION FOREGROUND_SERVICE FOREGROUND_SERVICE_LOCATION POST_NOTIFICATIONS WAKE_LOCK; do
  grep -q "android.permission.$P" "$M" || sed -i.bak "s#</manifest>#    <uses-permission android:name=\"android.permission.$P\" />\n</manifest>#" "$M"
done
rm -f "$M.bak"

# ---------- iPhone（只有 Mac 才会生成）----------
if [ "$(uname)" = "Darwin" ]; then
  if [ ! -d ios ]; then npx cap add ios; fi
  PL=ios/App/App/Info.plist
  PB=/usr/libexec/PlistBuddy
  add() { "$PB" -c "Delete :$1" "$PL" 2>/dev/null || true; "$PB" -c "Add :$1 string $2" "$PL"; }
  add NSLocationWhenInUseUsageDescription "送单时需要你的位置，让店里和顾客看到你到哪了"
  add NSLocationAlwaysAndWhenInUseUsageDescription "送单时即使切换到别的 App 或锁屏，也要持续上报你的位置"
  "$PB" -c "Delete :UIBackgroundModes" "$PL" 2>/dev/null || true
  "$PB" -c "Add :UIBackgroundModes array" "$PL"
  "$PB" -c "Add :UIBackgroundModes:0 string location" "$PL"
fi

npx cap sync
echo
echo "完成。接下来："
echo "  Android：npx cap open android   （用 Android Studio 打开，菜单 Build → Build APK）"
if [ "$(uname)" = "Darwin" ]; then echo "  iPhone ：npx cap open ios       （用 Xcode 打开，设置好 Team 后 Product → Archive）"; fi
