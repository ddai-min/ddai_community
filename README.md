# ddai_community

Community App

## Client

<img src="https://img.shields.io/badge/flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white">

## Backend

<img src="https://img.shields.io/badge/firebase-DD2C00?style=for-the-badge&logo=firebase&logoColor=white">

## Architecture

/ddai_community  
│── 📁 lib  
│   ├── 📁 board        # 게시글 관련 소스 코드  
│   ├── 📁 chat         # 채팅 관련 소스 코드  
│   ├── 📁 common       # 공통 사용 소스 코드  
│   ├── 📁 user         # 회원가입, 로그인 등 유저 관련 소스 코드

📁 component        # 재사용 widget  
📁 model            # api용 json 모델  
📁 provider         # 상태관리를 위한 riverpod provider  
📁 repository       # firebase 송수신

📁 const            # 상수 집합  
📁 converter        # json 타입 변환  
📁 layout           # 공통 layout widget  
📁 router           # 라우팅  
📁 util             # 데이터 변환

📁 view             # 실제 보여지는 widget

## Using Packages

- [cupertino_icons](https://pub.dev/packages/cupertino_icons)
- [go_router](https://pub.dev/packages/go_router)
- [json_annotation](https://pub.dev/packages/json_annotation)
- [firebase_core](https://pub.dev/packages/firebase_core)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [firebase_storage](https://pub.dev/packages/firebase_storage)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [logger](https://pub.dev/packages/logger)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
- [image_picker](https://pub.dev/packages/image_picker)

## Using Dev Packages

- [flutter_lints](https://pub.dev/packages/flutter_lints)
- [build_runner](https://pub.dev/packages/build_runner)
- [json_serializable](https://pub.dev/packages/json_serializable)