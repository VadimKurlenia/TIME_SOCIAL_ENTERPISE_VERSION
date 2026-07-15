# Архитектура БД (PostgreSQL)

---

## `users` — Пользователи
- **Поля:** `id`(PK), `email`(UNIQUE), `avatar_url`, `profile_banner_url`, `privacy_default`, `notify_meeting_rsvp_changes`, `theme`, `language`, `timezone`.
- **Правила:** Email валидируется на приложении. Для `privacy_default`, `theme`, `language`, `timezone` — ограничить допустимые значения (`CHECK`/`ENUM`).

---

## friendships — Связи (заявки/друзья/блок)

* Поля: user_id(FK), friend_id(FK), action_user_id(FK), status, user_visibility_level, friend_visibility_level.
* user_visibility_level — какой уровень доступа предоставляет пользователь user_id для friend_id.
* friend_visibility_level — какой уровень доступа предоставляет пользователь friend_id для user_id
* Составной PK: (user_id, friend_id).
* Индексы: по (user_id, status) и (friend_id, status) для выборки списков друзей.
* Правила:
* CHECK (user_id < friend_id) — исключает дубли и убирает OR из проверок.
   * status: pending, accepted, blocked.
   * visibility_level: full, busy_only, none.

---

## `friend_groups` — Группы контактов
- **Поля:** `id`(PK), `creator_id`(FK), `name`.
- **Индексы:** по `creator_id`.

---

## `friend_group_members` — Участники групп
- **Поля:** `group_id`(FK, CASCADE), `member_id`(FK, CASCADE).
- **Составной PK:** (group_id, member_id)
- **Индексы:** UNIQUE `(group_id, member_id)`.
- **Правила:** При добавлении проверять `friendships.status = 'accepted'` с создателем.

---

## `availability_blocks`
- **Поля:** `id`(PK), `user_id`(FK, CASCADE), `type`, `start_time`, `end_time`, `recurrence_rule`, `visibility`, `auto_status`, `status_auto_block`, `comm_availability`, `color`, `recurrence_end`.
- **Индексы:** по `user_id`; частичный для `one_time` по `(user_id, start_time, end_time)`.
- **Правила:**
  - `CHECK (start_time < end_time)`.
  - `type`: `one_time`, `recurring`, `exception`.
  - `visibility`: `only_me`, `friends`, `everyone`, `group`. Для `group` — проверка через `friend_group_members`.
  - `auto_status`/`status_auto_block`: `busy`, `free`, `dnd`, `bored`.
  - `comm_availability`: `unrestricted`, `calls_only`, `chats_only`, `unavailable`.
  - **Recurring:** не фильтруются в SQL; разворачиваются в коде через `expandRrule()`. Синтетический ID: `<uuid>_occ_<offset>`.
- **Важная информация::**
  - В функции expandRrule(rrule_str, start_date, end_date) аргументы start_date и end_date должны быть обязательными и жестко соответствовать запрашиваемому экрану во Flutter (например, текущий месяц + 1 неделя буфера). Нужно для того, чтоб не было бесконечных правил!!
---

## `block_guests` — Гости блоков
- **Поля:** `block_id`(PK, FK, CASCADE), `guest_id`(PK, FK, CASCADE).
- **Индексы:** составной PK.

---

## `block_visibility_groups` — Группы доступа к блоку
- **Поля:** `block_id`(PK, FK, CASCADE), `group_id`(PK, FK, CASCADE).
- **Индексы:** составной PK.
- **Правила:** При `visibility='group'` JOIN с `friend_group_members` для проверки доступа.

---

## `statuses` — История статусов пользователя
- **Поля:** `id`(PK), `user_id`(FK, CASCADE), `type`, `label`, `started_at`, `expires_at`.
- **Индексы:** по `(user_id, started_at DESC)`.
- **Правила:**
  - `type`: `busy`, `free`, `dnd`, `bored`, `custom`.
  - `label` — только при `type='custom'`.
  - Актуальный статус — последняя запись. Если `expires_at < now()` — статус недействителен.

---

### `event_proposals` — Предложения встреч
- **Поля:** `id` (PK), `creator_id` (FK, CASCADE), `status`, `proposed_slots` (JSONB), `confirmed_slot` (JSONB, NULL), `response_change_policy`, `allow_participant_invites`.
- **Индексы:** по `creator_id`.
- **Правила:**
  - `status`: `draft`, `voting`, `paused`, `confirmed`, `cancelled`.
  - В `paused` голосование запрещено.
  - При `confirmed`: создание `availability_block` и добавление проголосовавших в `block_guests` в рамках одной транзакции.

### `event_proposal_participants` — Участники предложений
- **Поля:** `proposal_id` (FK, CASCADE), `user_id` (FK, CASCADE), `is_archived` (BOOLEAN), `is_muted` (BOOLEAN).
- **Составной PK:** `(proposal_id, user_id)`.
- **Индексы:** B-Tree по `(user_id, is_archived, is_muted)` для выборки активных и архивных списков.
- **Правила:** Заменяет массивы `archived_by_users`/`muted_by_users` и исключает блокировки строк (Race Condition) при действиях пользователей.

---

## `proposal_votes` — Голоса участников
- **Поля:** `id`(PK), `proposal_id`(FK, CASCADE), `voter_id`(FK, CASCADE), `attendance_status`, `voted_slots`(JSONB).
- **Индексы:** UNIQUE `(proposal_id, voter_id)` → UPSERT.
- **Правила:**
  - `attendance_status`: `yes`, `no`, `maybe`, `left` (мягкое удаление).
  - При `left` запись сохраняется.

---

## `meeting_messages` — Чат встречи
- **Поля:** `id`(PK), `proposal_id`(FK, CASCADE), `user_id`(FK, CASCADE), `content`, `created_at`.
- **Индексы:** по `(proposal_id, created_at ASC)`.
- **Правила:** Плоский чат, без редактирования/удаления.

---

## `notifications` — Уведомления + Личные чаты
- **Поля:** `id`(PK), `user_id`(FK, CASCADE), `type`, `channel`, `is_read`, `payload`(JSONB), `created_at`.
- **Индексы:** частичный по `(user_id, is_read)` для непрочитанных; GIN по `payload` (payload->>'fromId'), (payload->>'toId')
- **Правила:**
  - Личные чаты → `type='system'`, `payload: { fromId, toId, text }`.
  - Группировка диалогов — в коде бэкенда.
  - WebSocket-трансляция для Flutter и Next.js.

---

## `activity_feed` — Лента активности (Fan-out-on-write)
- **Поля:** `id`(PK), `viewer_id`(FK, CASCADE), `actor_id`(FK, CASCADE), `actor_name`, `actor_avatar_url`, `type`, `payload`(JSONB), `created_at`.
- **Индексы:** по `(viewer_id, created_at DESC)`.
- **Правила:** Одно действие → запись для каждого друга (`viewer_id`). Денормализованы `actor_name` и `actor_avatar_url`.

---

## `password_reset_tokens` — Токены сброса пароля
- **Поля:** `id`(PK), `user_id`(FK, CASCADE), `token_hash`(UNIQUE, NOT NULL), `created_at`, `expires_at`, `used_at`.
- **Индексы:** по `token_hash`; по `(user_id, created_at DESC)`.
- **Правила:**
  - Хранится только хэш токена.
  - Валидный: `used_at IS NULL` и `CURRENT_TIMESTAMP < expires_at`.