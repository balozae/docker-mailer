# Docker EXIM

Это образ с exim для отправки писем в сеть.

Используемая версия по-умолчанию - 4.92.3-r0.

Наружу будет торчать 25 порт. Нужно настроить Firewall.

IPv6 отключен.

## Как собрать образ

```bash
docker build -t registry.gitlab.com/example/example:4.92.3 .
docker push registry.gitlab.com/example/example:4.92.3
```

## Как запустить образ

Изменить переменные на свои:

- **IP_ADDRESS_CHANGEME** - исходящий IP адрес
- **HOSTNAME_CHANGEME** - hostname сервера
- **REGISTRY_URL_CHANGEME** - адрес registry, например: registry.gitlab.com/example/example

Создать сеть

```bash
docker network create --attachable \
 --opt "com.docker.network.bridge.name=nw-bridge" \
 nw-bridge
```

Запуск контейнера

```bash
docker run -d \
 -h HOSTNAME_CHANGEME \
 --restart on-failure \
 --volume /app/dkim:/dkim \
 --name exim \
 --network nw-bridge \
 -p 127.0.0.1:25:25 \
 --dns 1.1.1.1 \
 REGISTRY_URL_CHANGEME
```

При запуске будет созданы DKIM файлы (если их нет) в `/app/dkim` (папка монтируется выше).
Имена файлов - это `hostname` и `hostname.pub`

## Конфигурация

Все параметры необязательны

| ENV               | Значение по-умолчанию                   | Описание                    |
| ----------------- | --------------------------------------- | --------------------------- |
| DKIM_SELECTOR     | mail                                    | селектор DKIM в DNS записях |
| DKIM_KEY_SIZE     | 1024                                    |                             |
| EXIM_VERSION      | 4.92.3-r0                               |                             |
| DKIM_SIGN_HEADERS | Date:From:To:Subject:Message-ID         |                             |
| RELAY_FROM_HOSTS  | 10.0.0.0/8:172.16.0.0/12:192.168.0.0/16 |                             |

### Если проблемы с iptables

eno1 - внешний интерфейс

```bash
iptables -A FORWARD -i nw-bridge -o eno1 -j ACCEPT
iptables -A FORWARD -i eno1 -o nw-bridge -j ACCEPT
iptables -t nat -A POSTROUTING ! -o nw-bridge -s 172.20.0.0/16 -j SNAT --to-source IP_ADDRESS_CHANGEME
```

## Тестирование

Вход в контейнер

```bash
docker exec -it exim sh
```

Отправка письма на mail-tester.com

```bash
sendmail example@mail-tester.com <<'EOF'
From: "The Great Quux" <admin@HOSTNAME_CHANGEME>
To: "example" <example@mail-tester.com>
Reply-To: admin@HOSTNAME_CHANGEME
Subject: Yay!
Content-Type: text/plain; charset=utf-8

My Mail
EOF
```
