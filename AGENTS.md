# paper-plane Agent Guide

"paperplane" 是一個Flutter/Dart專案

## 程式碼及架構
* 以Flutter/Dart程式碼為主，除非必要否則不異動android、ios、macos資料夾下的內容。
* Flutter使用BLoC/Cubit架構。
* iOS及MacOS只使用Swift，不使用Objective-C語法。不使用.storyboard或.xib等Xcode限定格式的檔案，只能使用SwiftUI開發畫面。
* Android只能使用Kotlin，不使用Java語法。
* 不論Dart、Swift或Kotlin都需符合SOLID原則，並遵循通用的與規範(Lint)

## 資料夾及檔案說明
* lib 為 Flutter/Dart主程式
* test 為 Flutter/Dart測試程式
