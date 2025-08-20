create extension if not exists "pgcrypto";

do $$ begin
  if not exists (select 1 from pg_class where relname = 'offers_internal_id_seq') then
    create sequence offers_internal_id_seq start 1;
  end if;
end $$;

create table if not exists public.offers (
  id uuid primary key default gen_random_uuid(),
  internal_id int not null default nextval('offers_internal_id_seq') unique,
  date date,
  vertical text,
  provider_type text check (provider_type in ('провайдер','прямой мерчант','агрегатор провайдер','агрегатор мерчант')),
  stake numeric,
  cheki numeric,
  insurance boolean default false,
  rolling_reserve boolean default false,
  settlement text
);

alter table public.offers enable row level security;

do $$ begin
  if not exists (select 1 from pg_policies where polname = 'offers_select_all') then
    create policy offers_select_all on public.offers for select using (true);
  end if;
  if not exists (select 1 from pg_policies where polname = 'offers_insert_all') then
    create policy offers_insert_all on public.offers for insert with check (true);
  end if;
  if not exists (select 1 from pg_policies where polname = 'offers_update_all') then
    create policy offers_update_all on public.offers for update using (true) with check (true);
  end if;
  if not exists (select 1 from pg_policies where polname = 'offers_delete_all') then
    create policy offers_delete_all on public.offers for delete using (true);
  end if;
end $$;
