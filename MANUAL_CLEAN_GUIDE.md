# 手动清理和构建指南

## 🧹 完整清理步骤

### 1. Flutter 清理
```bash
flutter clean
```

### 2. Android Gradle 清理
```bash
cd android
./gradlew clean
rm -rf .gradle/
rm -rf app/build/
rm -rf build/
cd ..
```

### 3. 删除其他构建文件
```bash
rm -rf build/
rm -rf .dart_tool/build/
```

### 4. 重新获取依赖
```bash
flutter pub get
```

## 🔨 构建步骤

### 1. 强制重新编译原生库
```bash
cd android
./gradlew :app:clean
./gradlew :app:assembleRelease --rerun-tasks
cd ..
```

### 2. 构建 AAB
```bash
flutter build appbundle --release --verbose
```

## ✅ 验证步骤

### 1. 检查文件是否生成
```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### 2. 使用 bundletool 验证（如果已安装）
```bash
# 安装 bundletool（如果还没有）
brew install bundletool

# 验证 16 KB 支持
bundletool dump config --bundle=build/app/outputs/bundle/release/app-release.aab | grep alignment
```

应该看到：`PAGE_ALIGNMENT_16K`

### 3. 检查 AAB 内容
```bash
unzip -l build/app/outputs/bundle/release/app-release.aab | grep "\.so$"
```

## 🚨 如果仍然失败

### 检查 Flutter 版本
```bash
flutter --version
```
确保使用 Flutter 3.24+ 版本

### 更新所有依赖
```bash
flutter pub upgrade
```

### 检查插件兼容性
特别关注这些包含原生代码的插件：
- camera: 0.10.5+9
- mobile_scanner: 4.0.1
- webview_flutter: ^4.4.4
- flutter_inappwebview: ^6.0.0
- permission_handler: ^11.3.1

### 强制更新 Flutter 引擎
```bash
flutter precache --force
```

## 📱 测试构建的应用

### 在真机上测试
```bash
# 构建 APK 用于测试
flutter build apk --release

# 安装到设备
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 检查应用是否正常运行
- 测试相机功能
- 测试扫码功能
- 测试 WebView 功能
- 测试所有核心功能

## 🎯 最终检查清单

- [ ] 完成所有清理步骤
- [ ] 重新构建 AAB
- [ ] 验证 16 KB 支持
- [ ] 在真机上测试
- [ ] 上传到 Google Play Console
- [ ] 检查是否还有 16 KB 警告

## 💡 提示

1. **每次修改配置后都要完整清理**
2. **使用 --verbose 标志查看详细构建日志**
3. **确保网络连接稳定**（下载依赖时）
4. **保留构建日志**以便排查问题

## 🔧 故障排除

### 如果 gradlew 权限错误
```bash
chmod +x android/gradlew
```

### 如果 NDK 找不到
检查 Android Studio SDK Manager 中是否安装了 NDK 27

### 如果构建超时
增加 Gradle 内存：
```bash
# 在 android/gradle.properties 中
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G
```

---

按照这个指南操作后，你的应用应该能够通过 Google Play 的 16 KB 页面大小检查。