# CargoAitu

Платформа автоматизации грузоперевозок с системой аукционов и электронной подписью (ЭЦП).

## Технологии

**Backend:**
- Python 3.11 + FastAPI
- PostgreSQL / SQLite
- Аутентификация через ЭЦП (NCALayer)
- Интеграция с egov API

**Frontend:**
- Vanilla JavaScript
- HTML/CSS

## Основные функции

- Создание заявок на перевозку с параметрами груза и маршрута
- Аукционная система (открытые торги)
- Управление водителями и транспортом
- Контракты и партнёрства между организациями
- Генерация документов (договоры, акты, счета-фактуры) с ЭЦП
- Интеграция с Google Maps
- Система уведомлений

## Установка (локально)

### Требования
- Python 3.11+
- PostgreSQL (опционально, по умолчанию SQLite)

### Backend

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# Отредактируй .env и добавь API ключи
python main.py
```

Backend запустится на `http://localhost:8000`

### Frontend

```bash
cd frontend
python dev_server.py
```

Frontend будет доступен на `http://localhost:8080`

## Деплой

См. [DEPLOY.md](DEPLOY.md) для инструкций по деплою на Render.com (бесплатно).

## Структура проекта

```
├── backend/              # FastAPI backend
│   ├── main.py          # Основной файл приложения
│   ├── database.py      # Модели БД
│   ├── models.py        # Pydantic модели
│   ├── ecp_utils.py     # Утилиты для работы с ЭЦП
│   ├── egov_api.py      # Интеграция с egov
│   └── templates/       # Шаблоны документов
├── frontend/            # Frontend приложение
│   ├── index.html       # Список заявок
│   ├── requests.js      # Логика заявок
│   ├── drivers.html     # Управление водителями
│   ├── trucks.html      # Управление транспортом
│   └── styles.css       # Стили
└── docs/                # Документация
```

## Лицензия

Проприетарное ПО
