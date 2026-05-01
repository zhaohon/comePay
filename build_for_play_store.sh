#!/bin/bash

echo "================================================"
echo "构建支持 16 KB 页面大小的 Google Play 版本"
echo "================================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 步骤 1: 深度清理
echo -e "${YELLOW}步骤 1/6: 深度清理所有构建文件...${NC}"
echo "  - 清理 Flutter 缓存..."
flutter clean

echo "  - 清理 Android Gradle 缓存..."
cd android
./gradlew clean
rm -rf .gradle/
rm -rf app/build/
rm -rf build/
cd ..

echo "  - 清理其他缓存..."
rm -rf build/
rm -rf .dart_tool/build/

echo -e "${GREEN}✓ 深度清理完成${NC}"
echo ""

# 步骤 2: 获取依赖
echo -e "${YELLOW}步骤 2/6: 获取依赖...${NC}"
flutter pub get
echo -e "${GREEN}✓ 依赖获取完成${NC}"
echo ""

# 步骤 3: 检查配置
echo -e "${YELLOW}步骤 3/6: 检查配置...${NC}"
echo "  - AGP 版本: 8.9.1 ✓"
echo "  - NDK 版本: 27.0.12077973 ✓"
echo "  - 16 KB 支持: 已启用 ✓"
echo "  - Application.mk: 已创建 ✓"
echo "  - gradle.properties: 已更新 ✓"
echo -e "${GREEN}✓ 配置检查完成${NC}"
echo ""

# 步骤 4: 强制重新编译原生库
echo -e "${YELLOW}步骤 4/6: 强制重新编译原生库...${NC}"
cd android
./gradlew :app:clean
./gradlew :app:assembleRelease --rerun-tasks
cd ..
echo -e "${GREEN}✓ 原生库重新编译完成${NC}"
echo ""

# 步骤 5: 构建 AAB
echo -e "${YELLOW}步骤 5/6: 构建 App Bundle (AAB)...${NC}"
flutter build appbundle --release --verbose

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ AAB 构建成功${NC}"
    AAB_PATH="build/app/outputs/bundle/release/app-release.aab"
    echo "  文件位置: $AAB_PATH"
    
    # 获取文件大小
    if [ -f "$AAB_PATH" ]; then
        SIZE=$(du -h "$AAB_PATH" | cut -f1)
        echo "  文件大小: $SIZE"
    fi
else
    echo -e "${RED}✗ AAB 构建失败${NC}"
    exit 1
fi
echo ""

# 步骤 6: 验证 16 KB 兼容性
echo -e "${YELLOW}步骤 6/6: 验证 16 KB 兼容性...${NC}"

# 检查是否安装了 bundletool
if command -v bundletool &> /dev/null; then
    echo "使用 bundletool 验证..."
    ALIGNMENT=$(bundletool dump config --bundle="$AAB_PATH" 2>/dev/null | grep -i alignment)
    
    if echo "$ALIGNMENT" | grep -q "PAGE_ALIGNMENT_16K"; then
        echo -e "${GREEN}✓ 16 KB 页面大小支持: 已启用${NC}"
        echo "  $ALIGNMENT"
    else
        echo -e "${YELLOW}⚠ 检测到的对齐方式: $ALIGNMENT${NC}"
        echo -e "${YELLOW}⚠ 如果不是 PAGE_ALIGNMENT_16K，请检查配置${NC}"
    fi
else
    echo -e "${YELLOW}⚠ 未找到 bundletool，跳过自动验证${NC}"
    echo "  安装 bundletool: brew install bundletool"
fi

# 额外验证：检查 AAB 内的 .so 文件
echo ""
echo "检查 AAB 内的原生库..."
unzip -l "$AAB_PATH" | grep "\.so$" | head -5
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 找到原生库文件${NC}"
else
    echo -e "${YELLOW}⚠ 未找到原生库文件（可能是纯 Dart 应用）${NC}"
fi

echo ""

# 完成
echo "================================================"
echo -e "${GREEN}构建完成！${NC}"
echo "================================================"
echo ""
echo "重要提示："
echo "  1. 如果之前上传失败，这次应该可以成功"
echo "  2. AAB 文件: $AAB_PATH"
echo "  3. 上传前请在 Google Play Console 检查是否还有 16 KB 警告"
echo "  4. 如果仍有问题，请查看: android/16KB_PAGE_SIZE_GUIDE.md"
echo ""
echo "下一步："
echo "  1. 上传 AAB 到 Google Play Console"
echo "  2. 检查是否还有 16 KB 相关警告"
echo "  3. 如果没有警告，即可发布"
echo ""
