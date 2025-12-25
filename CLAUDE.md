# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS SwiftUI 設備保養管理 App，targeting iOS 16.2+。使用 Mock 資料開發，支援離線功能。

## Build Commands

```bash
# Open in Xcode (recommended for development)
open famapp.xcodeproj

# Build from command line (requires Xcode)
xcodebuild -project famapp.xcodeproj -scheme famapp -configuration Debug build
```

## Testing

```bash
xcodebuild -project famapp.xcodeproj -scheme famapp test
```

## Architecture

MVVM 架構，使用 SwiftUI + Combine。

### 資料夾結構

```
famapp/
├── App/                          # App 層
│   ├── AppCoordinator.swift      # 導航與認證狀態管理
│   └── DependencyContainer.swift # 依賴注入
├── Models/
│   ├── Domain/                   # 領域模型
│   │   ├── WorkOrder.swift       # 工單 (含 ParentWorkOrder)
│   │   ├── MaintenanceProcedure.swift  # 保養作業程序
│   │   ├── Material.swift        # 材料
│   │   ├── Tool.swift            # 工具
│   │   ├── Manpower.swift        # 人力
│   │   ├── ApprovalRecord.swift  # 核簽紀錄
│   │   └── User.swift            # 使用者與認證
│   └── Enums/                    # 列舉
│       ├── WorkOrderStatus.swift # 待回報/已回報
│       ├── FilterType.swift      # 篩選條件
│       └── OrderType.swift       # PM/CM/巡檢/庫存
├── Services/
│   ├── Auth/                     # 認證服務
│   │   ├── AuthService.swift
│   │   └── KeychainManager.swift
│   ├── Data/
│   │   └── MockDataService.swift # Mock 資料 (實作 DataServiceProtocol)
│   └── Network/
│       └── NetworkMonitor.swift  # 網路狀態監控
├── Features/
│   ├── Authentication/           # 登入
│   │   ├── Views/LoginView.swift
│   │   └── ViewModels/LoginViewModel.swift
│   ├── WorkOrderList/            # 工單清單
│   │   ├── Views/
│   │   │   ├── MainView.swift    # 主畫面容器
│   │   │   ├── SideMenuView.swift # 側邊選單
│   │   │   ├── WorkOrderListView.swift
│   │   │   └── FilterBarView.swift
│   │   └── ViewModels/WorkOrderListViewModel.swift
│   ├── WorkOrderDetail/          # 工單明細
│   │   ├── Views/
│   │   │   ├── WorkOrderDetailView.swift
│   │   │   └── Tabs/
│   │   │       ├── OverviewTabView.swift      # 總覽 (含子頁籤)
│   │   │       ├── ManpowerTabView.swift      # 人力
│   │   │       ├── ToolsTabView.swift         # 工具
│   │   │       └── ApprovalRecordsTabView.swift # 核簽紀錄
│   │   └── ViewModels/WorkOrderDetailViewModel.swift
│   ├── Settings/                 # 設定
│   └── SystemInfo/               # 系統資訊
├── Components/                   # 共用元件
│   ├── LoadingView.swift
│   └── PrimaryButton.swift
└── Theme/                        # 主題
    ├── ThemeManager.swift
    └── AppColors.swift
```

### 關鍵設計模式

1. **環境物件注入** - AppCoordinator, ThemeManager, AuthService, NetworkMonitor 透過 `@EnvironmentObject` 注入
2. **Protocol-based Data Layer** - `DataServiceProtocol` 讓 MockDataService 可以輕鬆換成真實 API
3. **狀態驅動導航** - AppCoordinator.authState 控制登入/主畫面切換

### 工單結構

- **ParentWorkOrder** - 母工單，包含多個子工單
- **WorkOrder** - 子工單/資產，包含：
  - maintenanceProcedures (保養作業程序)
  - materials (材料)
  - manpower (人力)
  - tools (工具)
  - approvalRecords (核簽紀錄)

### 頁籤結構

工單明細畫面主頁籤：人力 → 工具 → 核簽紀錄 → 總覽
總覽子頁籤：工單 → 保養作業程序 → 材料

## 待實作功能

- Core Data 離線儲存
- 同步佇列 (SyncQueueManager)
- 照片拍攝與上傳
- 條碼掃描
- 進階查詢功能
