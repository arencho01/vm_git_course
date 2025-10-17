#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_git_repo() {
    if [ ! -d .git ]; then
        echo -e "${RED}Ошибка: Это не Git-репозиторий.${NC}"
        exit 1
    fi
}

check_git_config() {
    if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
        echo -e "${RED}Ошибка: Имя и email в Git не настроены.${NC}"
        exit 1
    fi
}

check_file_exists() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}Ошибка: Файл $1 не найден.${NC}"
        exit 1
    fi
}

check_commit_message() {
    if ! git log --grep="$1" --oneline | grep -q "$1"; then
        echo -e "${RED}Ошибка: Коммит с сообщением '$1' не найден.${NC}"
        exit 1
    fi
}

check_branch_exists() {
    if ! git branch --list | grep -q "$1"; then
        echo -e "${RED}Ошибка: Ветка $1 не существует.${NC}"
        exit 1
    fi
}

check_file_content() {
    if ! grep -q "$2" "$1"; then
        echo -e "${RED}Ошибка: В файле $1 не найдено '$2'.${NC}"
        exit 1
    fi
}

check_merge_conflict_resolved() {
    if ! grep -q "Логин: admin" login.txt || ! grep -q "Форма логина: username, password" login.txt; then
        echo -e "${RED}Ошибка: Конфликт в login.txt не разрешён правильно.${NC}"
        exit 1
    fi
}

check_remote_repo() {
    if ! git remote -v | grep -q "origin"; then
        echo -e "${YELLOW}Предупреждение: Удалённый репозиторий (origin) не привязан. Шаги 9-10 не проверены.${NC}"
    fi
}

check_last_commit_undone() {
    if git log --oneline | head -n 1 | grep -q "Update README"; then
        echo -e "${RED}Ошибка: Последний коммит ('Update README') не был отменён.${NC}"
        exit 1
    fi
}

### Основная проверка ###
echo -e "${GREEN}=== Начинаем проверку выполнения задания ===${NC}"

# 1. Проверяем, что это Git-репозиторий
check_git_repo
echo -e "${GREEN}✓ 1. Репозиторий инициализирован.${NC}"

# 2. Проверяем настройки имени и email
check_git_config
echo -e "${GREEN}✓ 2. Имя и email в Git настроены.${NC}"

# 3. Проверяем наличие README.md
check_file_exists "README.md"
echo -e "${GREEN}✓ 3. Файл README.md существует.${NC}"

# 4. Проверяем первый коммит
check_commit_message "Initial commit"
echo -e "${GREEN}✓ 4. Первый коммит 'Initial commit' найден.${NC}"

# 5. Проверяем наличие ветки feature/add-login
check_branch_exists "feature/add-login"
echo -e "${GREEN}✓ 5. Ветка feature/add-login существует.${NC}"

# 6. Проверяем файл login.txt в feature/add-login
git checkout feature/add-login &> /dev/null
check_file_exists "login.txt"
check_file_content "login.txt" "Форма логина: username, password"
check_commit_message "Add login form"
git checkout - &> /dev/null
echo -e "${GREEN}✓ 6. Ветка feature/add-login содержит login.txt с нужным содержимым и коммитом.${NC}"

# 7. Проверяем login.txt в master
check_file_exists "login.txt"
check_file_content "login.txt" "Логин: admin"
check_commit_message "Add admin login"
echo -e "${GREEN}✓ 7. В master создан login.txt с другим содержимым и коммитом.${NC}"

# 8. Проверяем слияние и разрешение конфликта
if ! git log --oneline | grep -q "Merge login feature"; then
    echo -e "${RED}Ошибка: Коммит слияния 'Merge login feature' не найден.${NC}"
    exit 1
fi
check_merge_conflict_resolved
echo -e "${GREEN}✓ 8. Конфликт слияния разрешён правильно.${NC}"

# 9. Проверяем наличие origin (не строгая проверка)
check_remote_repo
echo -e "${YELLOW}⚠ 9. Удалённый репозиторий проверен частично (вручную убедитесь, что master загружен).${NC}"

# 10. Проверяем откат коммита
check_last_commit_undone
echo -e "${GREEN}✓ 10. Коммит 'Update README' отменён.${NC}"

echo -e "${GREEN}\n=== Все шаги выполнены корректно! ===${NC}"
