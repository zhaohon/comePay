# Google Play 上传检查清单

## ✅ 16 KB 页面大小支持（已完成）

- [x] AGP 版本 >= 8.5.1（当前：8.9.1）
- [x] NDK 版本 >= 27（当前：27.0.12077973）
- [x] 添加 `ANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON` 配置
- [x] 配置 packaging 选项
- [x] 添加 NDK abiFilters

## 📋 构建前检查

- [ ] 更新版本号（当前：1.0.0+6）
  - 在 `pubspec.yaml` 中更新 `version: x.x.x+build_number`
  
- [ ] 检查签名配置
  - 确认 `android/key.properties` 文件存在
  - 确认包含正确的密钥信息

- [ ] 更新依赖到最新版本
  ```bash
  flutter pub upgrade
  ```

## 🔨 构建步骤

### 方法 1：使用提供的脚本（推荐）
```bash
chmod +x build_for_play_store.sh
./build_for_play_store.sh
```

### 方法 2：手动构建
```bash
# 1. 清理
flutter clean
cd android && ./gradlew clean && cd ..

# 2. 获取依赖
flutter pub get

# 3. 构建 AAB
flutter build appbundle --release

# 4. 构建的文件位置
# build/app/outputs/bundle/release/app-release.aab
```

## ✅ 构建后验证

### 1. 检查文件是否生成
```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### 2. 验证 16 KB 兼容性

#### 选项 A：使用 bundletool（推荐）
```bash
# 安装 bundletool（如果还没有）
brew install bundletool

# 验证
bundletool dump config --bundle=build/app/outputs/bundle/release/app-release.aab | grep alignment
```
应该看到：`PAGE_ALIGNMENT_16K`

#### 选项 B：使用 Android Studio
1. 打开 Android Studio
2. `Build > Analyze APK...`
3. 选择 AAB 文件
4. 检查 lib 文件夹中的 .so 文件对齐情况

#### 选项 C：使用提供的脚本
```bash
chmod +x android/verify_16kb.sh
./android/verify_16kb.sh build/app/outputs/bundle/release/app-release.aab
```

### 3. 测试应用
- [ ] 在真机上安装测试
- [ ] 测试所有核心功能
- [ ] 测试相机功能（camera 插件）
- [ ] 测试扫码功能（mobile_scanner 插件）
- [ ] 测试 WebView 功能

## 📤 上传到 Google Play

### 1. 登录 Google Play Console
https://play.google.com/console

### 2. 选择你的应用

### 3. 创建新版本
- 进入 `Production` 或 `Testing` track
- 点击 `Create new release`

### 4. 上传 AAB
- 上传 `build/app/outputs/bundle/release/app-release.aab`

### 5. 填写发布说明
- 添加版本更新说明
- 支持的语言版本

### 6. 审核并发布
- 检查所有警告和错误
- 确认 16 KB 兼容性通过
- 提交审核

## ⚠️ 常见问题

### 问题 1：上传后提示不支持 16 KB
**解决方案：**
1. 确认已按照本指南完成所有配置
2. 重新清理并构建
3. 使用验证工具确认兼容性

### 问题 2：构建失败
**解决方案：**
```bash
# 清理所有缓存
flutter clean
cd android && ./gradlew clean && cd ..
rm -rf build/
rm -rf android/.gradle/

# 重新获取依赖
flutter pub get

# 重新构建
flutter build appbundle --release
```

### 问题 3：某些插件不兼容
**解决方案：**
1. 更新所有插件到最新版本：`flutter pub upgrade`
2. 检查插件的 GitHub issues 页面
3. 如果插件不支持，寻找替代方案

### 问题 4：签名错误
**解决方案：**
1. 检查 `android/key.properties` 文件
2. 确认密钥库文件路径正确
3. 确认密码正确

## 📚 相关文档

- [16 KB 页面大小详细指南](android/16KB_PAGE_SIZE_GUIDE.md)
- [Android 官方文档](https://developer.android.com/guide/practices/page-sizes)
- [Flutter Android 部署](https://docs.flutter.dev/deployment/android)

## 🎯 快速命令参考

```bash
# 查看 Flutter 版本
flutter --version

# 查看 Gradle 版本
cd android && ./gradlew --version && cd ..

# 清理构建
flutter clean

# 获取依赖
flutter pub get

# 更新依赖
flutter pub upgrade

# 构建 AAB
flutter build appbundle --release

# 构建 APK（用于测试）
flutter build apk --release

# 查看构建文件
ls -lh build/app/outputs/bundle/release/
ls -lh build/app/outputs/flutter-apk/
```

## ✨ 提示

1. **始终使用 AAB 格式上传到 Google Play**（不是 APK）
2. **在上传前进行充分测试**
3. **保留构建日志**以便排查问题
4. **定期更新 Flutter 和依赖**
5. **关注 Google Play Console 的警告和建议**

---

最后更新：2026-04-11
