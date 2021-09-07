# Бюджетная система

(с) NAUMEN Public License

## Подготовка окружения

### 1. Склонируйте репозиторий

```bash
git clone git@github.com:naumen/budget.git
cd budget
```

### 2. Настройка окружения

#### 2.1 Скопируйте `.env` file

```bash
cp .env.template .env
```

#### 2.2 Установите `DIP (Docker Interaction Process)`

[DIP](https://github.com/bibendi/dip) - утилита командной строки, которая упрощает взаимодействие с сервисами,
настроенными с помощью Docker Compose.

```bash
gem install dip
```

Установить ruby gems, создать базу данных можно следующей командой:

```bash
dip provision
```

### 3. Запуск приложения

```bash
dip up
```

Перейдите в браузере по адресу [localhost:3000](http://localhost:3000)

Зайдите под пользователем:

```yaml
login: admin
password: Budget
```

### 4. Запуск тестов

Для запуска тестов, можно воспользоваться командой:

```bash
dip rails test
```

### Полезные команды

| Команда                                | Описание команды                                                                 |
| -------------------------------------- | -------------------------------------------------------------------------------- |
| `dip provision`                        | Сбросить тестовое и окружение разработчика, переустановить гемы и пересоздать БД |
| `dip up`                               | Запустить приложение                                                             |
| `dip down`                             | Остановить приложение                                                            |
| `dip rake ...`                         | Запуск `rake` команд. Например `dip rake db:migrate` запустит миграции           |
| `dip rails ...`                        | Запуск `rails` команд. Например `dip rails console`                              |
| `dip rails g migration CreateNewTable` | Сгенерировать миграцию                                                           |
| `dip bundle`                           | Запуск `bundle`                                                                  |
| `dip mysql`                            | Открыть клиент `mysql` с БД development окружения                                |
| `dip bash`                             | Запустить `bash` в контейнере                                                    |
| `dip compose ...`                      | Запустить `docker-compose` команды. Например `dip compose logs -f`               |
| `dip down --volumes`                   | Остановить запущенные контейнеры и удалить их `volumes`                          |
