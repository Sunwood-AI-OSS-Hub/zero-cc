---
name: browser-api
description: Cinderella Browser API を使用してブラウザ操作を行うスキル。ブラウザの自動化、スクリーンショット取得、ページ操作が必要な時に使用する。API は http://browser-api:8000、noVNC は http://localhost:7900
---

# Browser API

Cinderella Browser API は Playwright によるブラウザ自動化 API。

## API Base URL

```
http://browser-api:8000
```

**Note:** Docker ネットワーク内からはサービス名 `browser-api` でアクセス。ポートはコンテナ内の 8000。

## Endpoints

### `GET /health` - ブラウザ状態確認
```bash
curl http://browser-api:8000/health
```

### `POST /open` - URL を開く
```bash
curl -X POST http://browser-api:8000/open \
  -H "Content-Type: application/json" \
  -d '{"url": "https://example.com", "wait_until": "domcontentloaded"}'
```

### `GET /snapshot` - ページ上の要素一覧取得
```bash
curl http://browser-api:8000/snapshot
```

### `POST /click` - 要素クリック
```bash
curl -X POST http://browser-api:8000/click \
  -H "Content-Type: application/json" \
  -d '{"selector": "#submit-button"}'
```

### `POST /fill` - 入力フィールドに入力
```bash
curl -X POST http://browser-api:8000/fill \
  -H "Content-Type: application/json" \
  -d '{"selector": "#search", "value": "検索ワード"}'
```

### `GET /text` - 要素のテキスト取得
```bash
curl "http://browser-api:8000/text?selector=%23content"
```

### `POST /screenshot` - スクリーンショット撮影
```bash
curl -X POST http://browser-api:8000/screenshot \
  -H "Content-Type: application/json" \
  -d '{"path": "/app/screenshots/screenshot.png"}'
```

### `POST /close` - ブラウザを閉じる
```bash
curl -X POST http://browser-api:8000/close
```

## Typical Workflow

1. `GET /health` - ブラウザが起動しているか確認
2. `POST /open` - ページを開く
3. `GET /snapshot` - 操作したい要素のセレクタを確認
4. `POST /fill` + `POST /click` - 操作を実行
5. `POST /screenshot` - 結果をスクリーンショットで保存

## VNC Access

ブラウザ操作の様子をリアルタイムで確認できる：

- **VNC**: `localhost:5900`
- **noVNC**: http://localhost:7900
