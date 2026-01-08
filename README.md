# 🔔 리마인더 앱 (Reminder App)

Flutter로 제작된 모바일 중심의 할 일 관리 및 알림 애플리케이션입니다. 사용자가 할 일을 체계적으로 관리하고, 중요한 일정을 놓치지 않도록 로컬 알림 서비스를 제공합니다.

---

## 🚀 프로젝트 개요

이 프로젝트는 표준 Flutter 템플릿에서 시작하여 확장되었으며, 현재는 **인메모리(In-memory) 데이터 저장 방식**으로 동작합니다. 
> **주의:** 현재 버전은 데이터 영속성 레이어가 제거된 상태이므로, 앱을 완전히 종료하면 등록된 모든 할 일이 삭제됩니다.

### ✨ 주요 기능
* **할 일 관리:** 할 일(Task) 및 체크리스트 아이템 생성, 수정, 삭제.
* **알림 기능:** `flutter_local_notifications`를 통한 맞춤형 리마인더 알림.
* **홈 화면 위젯:** 안드로이드 홈 화면에서 할 일을 바로 확인할 수 있는 위젯 지원.
* **테마 모드:** 사용자 설정에 따른 라이트/다크 모드 전환.
* **다국어 지원:** `intl` 패키지를 활용한 한국어 날짜 및 시간 포맷팅.

---

## 🛠 기술 스택

| 분류 | 기술 |
| :--- | :--- |
| **Framework** | Flutter |
| **Language** | Dart |
| **State Management** | `flutter_riverpod` (StateNotifier Pattern) |
| **Notifications** | `flutter_local_notifications` |
| **Home Widget** | `home_widget` |
| **Database** | In-memory (Temporary storage) |

---

## 🏗 아키텍처 구조

본 프로젝트는 **Provider 기반의 클린 아키텍처**를 지향하며 관심사를 분리합니다.

* `lib/models`: 불변(Immutable) 데이터 모델 (`Task`, `ChecklistItem`).
* `lib/providers`: 앱 상태 관리 및 비즈니스 로직 (`TaskListNotifier` 등).
* `lib/screens`: UI 레이어 (홈 화면, 수정 화면 등).
* `lib/services`: 외부 API 및 플랫폼 기능 연동 (알림, 위젯 서비스).
* `docs/`: 프로젝트 상세 기획 및 설계 문서 (한국어).

---

## 💻 시작하기

### 의존성 설치
```bash
flutter pub get
