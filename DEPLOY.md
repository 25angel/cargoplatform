# Деплой на Render.com (бесплатно)

## Шаг 1: Подготовка

1. Создай аккаунт на [render.com](https://render.com)
2. Подключи свой GitHub аккаунт
3. Залей код на GitHub (если ещё не залит)

## Шаг 2: Создание базы данных

1. В Render dashboard нажми **New +** → **PostgreSQL**
2. Настройки:
   - **Name**: `cargoainur-db`
   - **Database**: `cargoainur`
   - **User**: `cargoainur`
   - **Region**: Frankfurt (ближе к Казахстану)
   - **Plan**: **Free**
3. Нажми **Create Database**
4. Скопируй **Internal Database URL** (понадобится для backend)

## Шаг 3: Деплой Backend (FastAPI)

1. Нажми **New +** → **Web Service**
2. Выбери свой GitHub репозиторий
3. Настройки:
   - **Name**: `cargoainur-backend`
   - **Region**: Frankfurt
   - **Branch**: `main` (или твоя ветка)
   - **Root Directory**: `backend`
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
   - **Plan**: **Free**

4. **Environment Variables** (добавь в секции Environment):
   ```
   DATABASE_URL = <вставь Internal Database URL из шага 2>
   GROQ_API_KEY = <твой ключ или оставь пустым>
   OPENAI_API_KEY = <твой ключ или оставь пустым>
   GOOGLE_MAPS_API_KEY = <твой ключ>
   ```

5. Нажми **Create Web Service**
6. Дождись деплоя (~5-10 минут)
7. Скопируй URL backend (например: `https://cargoainur-backend.onrender.com`)

## Шаг 4: Настройка Frontend

1. Открой `frontend/script.js` и измени:
   ```javascript
   const API_URL = 'https://cargoainur-backend.onrender.com/api';
   ```

2. Открой `frontend/requests.js` и измени:
   ```javascript
   const REQUESTS_API_URL = 'https://cargoainur-backend.onrender.com/api';
   ```

## Шаг 5: Деплой Frontend

1. Нажми **New +** → **Static Site**
2. Выбери свой GitHub репозиторий
3. Настройки:
   - **Name**: `cargoainur`
   - **Branch**: `main`
   - **Root Directory**: оставь пустым
   - **Build Command**: оставь пустым
   - **Publish Directory**: `frontend`
   - **Plan**: **Free**

4. Нажми **Create Static Site**

## Шаг 6: Настройка CORS на Backend

Добавь URL фронтенда в `backend/main.py`:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        'http://localhost:8080',
        'http://127.0.0.1:8080',
        'https://cargoainur.onrender.com'  # <-- добавь свой URL
    ],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*']
)
```

Закомить и запушить изменения — Render автоматически передеплоит.

## Ограничения бесплатного tier

- ⚠️ **Backend засыпает** после 15 минут неактивности (первый запрос будет медленным ~30-60 сек)
- ⚠️ **PostgreSQL** — 90 дней, потом нужно заново создать или перейти на платный
- ⚠️ **750 часов/месяц** лимит на работу сервисов
- ✅ **Файлы не сохраняются** между редеплоями (папка `contracts/` сбросится) — нужно добавить Render Disk ($1/мес) или использовать S3

## Альтернатива: Railway.app

Если Render не подойдёт, попробуй Railway — там $5 кредита/месяц и файлы сохраняются:
1. [railway.app](https://railway.app)
2. **New Project** → **Deploy from GitHub**
3. Добавь PostgreSQL через **New** → **Database** → **PostgreSQL**
4. Deployment автоматически настроится из `Procfile`

## Проверка

После деплоя:
1. Открой `https://твой-фронтенд.onrender.com`
2. Проверь авторизацию через ЭЦП (NCALayer работает на компьютере пользователя)
3. Создай тестовую заявку

Готово! 🚀
