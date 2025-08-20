# CRM Offers (Vue 3 + Vite + Supabase)

## Быстрый старт
1. Node.js 18+
2. `npm install`
3. `npm run dev` → http://localhost:5173
4. Ключи уже прописаны в `.env.local`

### Роли
- Стартовая страница — поиск по офферам
- Кнопка **Вход** ведёт на `/admin`: пароль `admin23`
- В админке: добавить/редактировать/удалять

## Деплой на Vercel
- `npm i -g vercel`
- `vercel` → `vercel --prod` (используется `vercel.json`)

## SQL
Смотрите `supabase/schema.sql` — создаёт таблицу `offers`, автонумератор для `internal_id` и общедоступные политики.
