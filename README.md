# Отчёт по практическому занятию №14

## Выполнил: Лазарев Г.С.

## Группа: ЭФБО-10-23

## Цели
- Реализовать дневник калорий по приёмам пищи (завтрак/обед/ужин/перекус) с БЖУ.
- База блюд с публикацией/фото: локальные и глобальные (Supabase), сортировка по популярности/адекватности.
- Авторизация/регистрация (Supabase Auth), сохранение дневников и блюд на пользователя.
- Написать unit/widget-тесты, настроить линтинг и подготовить шаги профилирования/оптимизации.

## Среда
- Flutter 3.10.3 / Dart 3.1 (sdk constraint 3.10.3).
- Пакеты: `supabase_flutter`, `shared_preferences`, `image_picker`, `flutter_localizations`.
- iOS: добавлены разрешения на камеру/галерею в `ios/Runner/Info.plist`.

## Реализация
- `lib/models.dart`: модели Dish (с описанием/фото/публикацией/usage), MealEntry, DailyLog, seed публичных блюд.
- `lib/storage.dart`: локальный стораж per-user (SharedPreferences, ключ с userId).
- `lib/supabase_service.dart`: инициализация Supabase, auth, загрузка/публикация блюд в `public_dishes`, приватные `user_dishes`, дневники `user_logs`, загрузка фото в bucket `dish_photos`.
- `lib/app_state.dart`: управление состоянием, суммаризация БЖУ, поиск/сортивка популярных, переключение пользователя по сессии Supabase.
- `lib/main.dart`: UI с двумя вкладками (День, Блюда), календарь, добавление блюд по приёмам, форма блюда (фото, описание, публикация), каталог с детальной карточкой (фото/описание/БЖУ/добавить в дневник), auth-экран с подсказкой про подтверждение email.

## Тестирование
- Unit: `test/app_state_test.dart` — расчёт БЖУ, сортировка по адекватности, переключение публикации.
- Widget: `test/dish_picker_test.dart` — популярные блюда и поиск в пикере.
- Запуск: `flutter test` (добавь `--coverage` при необходимости).  
  _Не запускалось здесь — прогоните локально и снимите цифру покрытия._

## Линтинг
- `analysis_options.yaml` включает `flutter_lints`.  
- Команда: `flutter analyze` (снимите скриншот/лог «до/после», если нужно).

## Supabase (обязательно заполнить `lib/config.dart` или dart-define)
1) Таблицы:
```sql
alter table public_dishes add column if not exists description text;
alter table user_dishes add column if not exists description text;
-- если таблиц ещё нет:
create table public_dishes (
  id text primary key,
  name text not null,
  calories int not null,
  proteins double precision not null,
  fats double precision not null,
  carbs double precision not null,
  description text,
  image_url text,
  usage_count int default 0,
  created_at timestamptz default now()
);
create table user_dishes (
  user_id uuid references auth.users(id) on delete cascade,
  id text not null,
  name text not null,
  calories int not null,
  proteins double precision not null,
  fats double precision not null,
  carbs double precision not null,
  description text,
  image_url text,
  usage_count int default 0,
  created_at timestamptz default now(),
  primary key (user_id, id)
);
create table user_logs (
  user_id uuid references auth.users(id) on delete cascade,
  date text not null,
  entries jsonb not null,
  created_at timestamptz default now(),
  primary key (user_id, date)
);
create or replace function increment_usage(dish_id text) returns void language plpgsql as $$
begin update public_dishes set usage_count = usage_count + 1 where id = dish_id; end; $$;
```
2) RLS для user_*: включить и добавить policy «own read/write/update» (auth.uid() = user_id).  
3) Storage: bucket `dish_photos` — публичное чтение, запись для authenticated.  
4) Auth: email+password, подтвердить email после регистрации (приложение покажет подсказку).

## Краткие инструкции по функционалу
- Вкладка «День»: выбрать дату, добавить блюдо в приём, итоги БЖУ по дню.
- Вкладка «Блюда»: мои блюда (переключатель публикации), каталог пользователей с сортировкой по популярности/адекватности, детальная карточка с описанием и кнопкой «Добавить в дневник».
- Публикация требует фото; при входе через Supabase данные дневника/блюд привязаны к аккаунту.

## Команды для проверки
- Линт: `flutter analyze`
<img width="1437" height="267" alt="2025-12-19_03-24-56" src="https://github.com/user-attachments/assets/f72769de-7d68-4e08-bd32-2946ef73a6b3" />
<img width="387" height="37" alt="2025-12-19_03-30-38" src="https://github.com/user-attachments/assets/95a61a72-3462-4fcd-99ec-ab4ac973676f" />

- Тесты: `flutter test --coverage`
<img width="1442" height="171" alt="2025-12-19_03-30-28" src="https://github.com/user-attachments/assets/360382fd-a4b0-4eea-a634-6372a83e71f1" />
<img width="387" height="37" alt="2025-12-19_03-30-38" src="https://github.com/user-attachments/assets/852b283a-0d32-4d97-a0dd-628d13abc906" />

- Сборка android: `flutter build apk`
<img width="471" height="111" alt="image" src="https://github.com/user-attachments/assets/4dc4b915-3b2f-4d43-be17-5fc6f5d98cfd" />

- Анализ размера: `flutter build apk --release --analyze-size`
<img width="892" height="422" alt="2025-12-19_03-38-49" src="https://github.com/user-attachments/assets/8ec5d09b-4843-4e54-8f8a-c3273f9df9da" />

