# Бюджетная система

(с) NAUMEN Public License

## Подготовка окружения

### 1. Клонировать репозиторий

```bash
git clone git@github.com:naumen/budget.git
cd budget
```

### 2. Настройка окружения

#### 2.1 Создать файл `.env`

```bash
cp .env.template .env
```

#### 2.2 Установить Docker Engine / Docker Compose

* [Install Docker Engine](https://docs.docker.com/engine/install/)
* [Install Docker Composer](https://docs.docker.com/compose/install/)

#### 2.3 Установить `DIP (Docker Interaction Process)`

[DIP](https://github.com/bibendi/dip) - утилита командной строки, которая упрощает взаимодействие с сервисами,
настроенными с помощью Docker Compose.

```bash
gem install dip
```

#### 2.4 Создание контейнера

```bash
dip provision
```

### 3. Запуск приложения

```bash
dip up
```

Перейти в браузере по адресу [localhost:3000](http://localhost:3000)

Зайти под пользователем:

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
