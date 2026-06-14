# paper-plane Agent Guide

"paperplane" 是一個 Flutter/Dart 專案。

## 專案目錄結構
* Flutter 專案位於 `paperplane/` 子目錄（非 repo 根目錄）
* 所有 flutter 指令必須在 `paperplane/` 目錄下執行
* 使用 FVM 管理 Flutter SDK 版本

## 常用指令（在 paperplane/ 下執行）
* `flutter pub get` — 安裝依賴
* `flutter analyze` — 靜態分析（lint）
* `flutter test` — 執行測試

## 程式碼及架構
* 使用 BLoC/Cubit 架構（flutter_bloc 套件）
* 3 個 Cubit：JoystickCubit、PlaneCubit、ZoomCubit
* JoystickState 和 ZoomState 使用 Dart 3 sealed class
* PlaneState 為一般 immutable class
* 單一頁面應用：MapPage（StatefulWidget）
* 使用 flutter_map 顯示 OpenStreetMap，已停用內建互動（InteractiveFlag.none），改用自製搖桿及縮放控制
* 無 codegen（無 build_runner、無 .g.dart、無 .freezed.dart）

## 平台約束
* 以 Flutter/Dart 程式碼為主，除非必要否則不異動 android、ios、macos 資料夾
* iOS 及 macOS 只用 Swift，不使用 Objective-C，不使用 .storyboard 或 .xib，只能用 SwiftUI 開發畫面
* Android 只用 Kotlin，不使用 Java
* 所有程式碼需符合 SOLID 原則並遵循 lint 規範

## 測試
* 測試檔位於 `paperplane/test/widget_test.dart`
* 執行指令：`flutter test`（在 paperplane/ 下）
