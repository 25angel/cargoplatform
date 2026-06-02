#!/bin/bash

# Скрипт автоматической установки CargoAitu
# Запуск: bash install.sh

set -e  # Остановка при ошибке

echo "🚀 Установка CargoAitu..."
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Проверка Python
echo "📦 Проверка Python..."
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 не найден. Установите Python 3.9+${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
echo -e "${GREEN}✅ Python найден: $(python3 --version)${NC}"

# Проверка и обновление pip
echo "📦 Проверка pip..."
if ! command -v pip3 &> /dev/null; then
    echo -e "${YELLOW}⚠️  pip3 не найден, устанавливаю...${NC}"
    python3 -m ensurepip --upgrade
fi

# Обновляем pip до последней версии
echo "🔄 Обновление pip до последней версии..."
if python3 -m pip install --upgrade pip --quiet 2>/dev/null; then
    echo -e "${GREEN}✅ pip обновлен${NC}"
else
    # Пробуем с --user если не получилось
    if python3 -m pip install --upgrade pip --user --quiet 2>/dev/null; then
        echo -e "${GREEN}✅ pip обновлен (установлен в пользовательскую директорию)${NC}"
    else
        echo -e "${YELLOW}⚠️  Не удалось обновить pip, продолжаю с текущей версией${NC}"
    fi
fi

PIP_VERSION=$(pip3 --version 2>/dev/null || python3 -m pip --version 2>/dev/null || echo "неизвестна")
echo -e "${GREEN}✅ pip найден: $PIP_VERSION${NC}"

# Переход в директорию backend
cd "$(dirname "$0")/backend" || exit 1

# Проверка и создание .env файла
echo ""
echo "📝 Настройка переменных окружения..."
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  Файл .env не найден, создаю из .env.example...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Файл .env создан${NC}"
        echo -e "${YELLOW}⚠️  ВАЖНО: Отредактируйте .env и добавьте API ключи (Google Maps, Groq/OpenAI)${NC}"
    else
        echo -e "${YELLOW}⚠️  .env.example не найден, создаю пустой .env${NC}"
        touch .env
    fi
else
    echo -e "${GREEN}✅ Файл .env уже существует${NC}"
fi

# Установка зависимостей Python
echo ""
echo "📦 Установка Python зависимостей..."
echo "Это может занять несколько минут..."

# Проверяем, поддерживает ли pip флаг --break-system-packages
PIP_SUPPORTS_BREAK_SYSTEM=""
if pip3 install --help 2>/dev/null | grep -q "break-system-packages"; then
    PIP_SUPPORTS_BREAK_SYSTEM="--break-system-packages"
fi

# Определяем флаги для pip
PIP_FLAGS=""
if [[ "$OSTYPE" == "darwin"* ]] && [ -n "$PIP_SUPPORTS_BREAK_SYSTEM" ]; then
    # macOS - используем --break-system-packages только если поддерживается
    PIP_FLAGS="--break-system-packages"
fi

# Пробуем установить зависимости
INSTALL_SUCCESS=false

# Попытка 1: с флагами (если есть)
if [ -n "$PIP_FLAGS" ]; then
    echo -e "${YELLOW}Попытка установки с флагами...${NC}"
    if pip3 install -r requirements.txt $PIP_FLAGS 2>&1 | tee /tmp/pip_install.log; then
        INSTALL_SUCCESS=true
    fi
fi

# Попытка 2: без флагов
if [ "$INSTALL_SUCCESS" = false ]; then
    echo -e "${YELLOW}Попытка установки без дополнительных флагов...${NC}"
    if pip3 install -r requirements.txt 2>&1 | tee /tmp/pip_install.log; then
        INSTALL_SUCCESS=true
    fi
fi

# Попытка 3: с --user
if [ "$INSTALL_SUCCESS" = false ]; then
    echo -e "${YELLOW}Попытка установки в пользовательскую директорию...${NC}"
    if pip3 install -r requirements.txt --user 2>&1 | tee /tmp/pip_install.log; then
        INSTALL_SUCCESS=true
    fi
fi

# Проверяем результат
if [ "$INSTALL_SUCCESS" = true ]; then
    echo -e "${GREEN}✅ Зависимости установлены${NC}"
else
    echo -e "${RED}❌ Ошибка установки зависимостей${NC}"
    echo -e "${YELLOW}Последние строки лога:${NC}"
    tail -20 /tmp/pip_install.log 2>/dev/null || true
    echo ""
    echo -e "${YELLOW}Попробуйте установить вручную:${NC}"
    echo "  cd backend"
    echo "  pip3 install -r requirements.txt"
    exit 1
fi

# Установка WeasyPrint зависимостей (для macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo "📦 Проверка зависимостей WeasyPrint для macOS..."
    if ! brew list cairo pango gdk-pixbuf gobject-introspection &> /dev/null; then
        echo -e "${YELLOW}⚠️  Устанавливаю системные зависимости для WeasyPrint...${NC}"
        if command -v brew &> /dev/null; then
            brew install cairo pango gdk-pixbuf gobject-introspection || {
                echo -e "${YELLOW}⚠️  Homebrew не найден или ошибка установки. Продолжаю без WeasyPrint зависимостей.${NC}"
            }
        else
            echo -e "${YELLOW}⚠️  Homebrew не найден. Установите вручную: brew install cairo pango gdk-pixbuf gobject-introspection${NC}"
        fi
    else
        echo -e "${GREEN}✅ Системные зависимости WeasyPrint установлены${NC}"
    fi
fi

# Инициализация базы данных
echo ""
echo "🗄️  Инициализация базы данных..."
if python3 -c "from database import init_db; init_db()" 2>/dev/null; then
    echo -e "${GREEN}✅ База данных инициализирована${NC}"
else
    echo -e "${YELLOW}⚠️  Предупреждение при инициализации БД (может быть нормально, если БД уже существует)${NC}"
fi

# Проверка подключения к PostgreSQL (если настроен)
if grep -q "DATABASE_URL=postgresql" .env 2>/dev/null; then
    echo ""
    echo "🔗 Проверка подключения к PostgreSQL..."
    if python3 -c "from database import engine; engine.connect().close()" 2>/dev/null; then
        echo -e "${GREEN}✅ Подключение к PostgreSQL успешно${NC}"
    else
        echo -e "${YELLOW}⚠️  Не удалось подключиться к PostgreSQL. Проверьте DATABASE_URL в .env${NC}"
    fi
fi

echo ""
echo -e "${GREEN}✅ Установка завершена!${NC}"
echo ""
echo "📋 Следующие шаги:"
echo ""
echo "1️⃣  Отредактируйте backend/.env и добавьте API ключи:"
echo "   - GOOGLE_MAPS_API_KEY"
echo "   - GROQ_API_KEY (или OPENAI_API_KEY)"
echo ""
echo "2️⃣  Если используете общую базу данных PostgreSQL:"
echo "   - Добавьте DATABASE_URL в backend/.env"
echo ""
echo "3️⃣  Запустите сервер:"
echo "   cd backend"
echo "   ./start.sh"
echo ""
echo "4️⃣  Откройте в браузере:"
echo "   http://localhost:8080"
echo ""

