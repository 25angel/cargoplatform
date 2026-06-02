#!/bin/bash

# Скрипт для первой заливки проекта на GitHub

echo "🔍 Инициализация Git репозитория..."
git init

echo "📝 Добавление файлов (игнорируя файлы из .gitignore)..."
git add .

echo "📊 Показываю что будет залито:"
git status

echo ""
echo "⚠️  ВАЖНО: Проверь список файлов выше!"
echo "   Убедись что НЕ добавлены:"
echo "   - .env файлы"
echo "   - *.db базы данных"
echo "   - *.p12 сертификаты"
echo "   - папка contracts/"
echo "   - папка __pycache__/"
echo ""
read -p "Продолжить? (y/n): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "❌ Отменено"
    exit 1
fi

echo "💾 Создание первого коммита..."
git commit -m "Initial commit: CargoAitu platform with contract security fixes"

echo ""
echo "✅ Репозиторий готов!"
echo ""
echo "Следующие шаги:"
echo "1. Создай репозиторий на GitHub: https://github.com/new"
echo "2. Выполни команды:"
echo ""
echo "   git remote add origin https://github.com/ТВОЙ_USERNAME/cargoainur.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
