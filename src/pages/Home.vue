<template>
  <div class="container">
    <div class="card" style="margin-bottom:16px">
      <h2 style="margin:0 0 12px 0">Поиск офферов</h2>
      <div class="grid grid-3">
        <div>
          <label class="label">Вертикаль</label>
          <select v-model="filters.vertical" class="select">
            <option value="">Любая</option>
            <option v-for="v in verticals" :key="v" :value="v">{{ v }}</option>
          </select>
        </div>

        <div>
          <label class="label">Тип провайдера</label>
          <select v-model="filters.provider_type" class="select">
            <option value="">Любой</option>
            <option v-for="t in providerTypes" :key="t" :value="t">{{ t }}</option>
          </select>
        </div>

        <div>
          <label class="label">Ставка, % (≥)</label>
          <input v-model.number="filters.stakeMin" type="number" min="0" step="0.01" class="input" placeholder="например, 3" />
        </div>

        <div>
          <label class="label">Чеки, от</label>
          <input v-model.number="filters.chekiMin" type="number" min="0" step="0.01" class="input" placeholder="например, 1000" />
        </div>

        <div>
          <label class="label">Страховой</label>
          <select v-model="filters.insurance" class="select">
            <option value="">Любой</option>
            <option value="true">Да</option>
            <option value="false">Нет</option>
          </select>
        </div>

        <div>
          <label class="label">Роллинг-резерв</label>
          <select v-model="filters.rolling_reserve" class="select">
            <option value="">Любой</option>
            <option value="true">Да</option>
            <option value="false">Нет</option>
          </select>
        </div>

        <div>
          <label class="label">Сеттлмент (поиск по тексту)</label>
          <input v-model="filters.settlementQuery" type="text" class="input" placeholder="например, T+3" />
        </div>
      </div>

      <div style="margin-top:12px; display:flex; gap:8px; flex-wrap: wrap">
        <button class="btn btn-primary" @click="load">Искать</button>
        <button class="btn" @click="clearFilters">Сбросить</button>
      </div>
    </div>

    <div v-if="loaded" class="card">
      <h3 style="margin:0 0 10px 0">Результаты</h3>
      <table class="table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Внутр. ID</th>
            <th>Дата</th>
            <th>Вертикаль</th>
            <th>Тип провайдера</th>
            <th>Ставка %</th>
            <th>Чеки</th>
            <th>Страховой</th>
            <th>Роллинг</th>
            <th>Сеттлмент</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="o in items" :key="o.id">
            <td>{{ o.id }}</td>
            <td>{{ o.internal_id }}</td>
            <td>{{ o.date }}</td>
            <td>{{ o.vertical }}</td>
            <td>{{ o.provider_type }}</td>
            <td>{{ fmt(o.stake) }}</td>
            <td>{{ fmt(o.cheki) }}</td>
            <td>{{ o.insurance ? 'Да' : 'Нет' }}</td>
            <td>{{ o.rolling_reserve ? 'Да' : 'Нет' }}</td>
            <td>{{ o.settlement || '' }}</td>
          </tr>
          <tr v-if="items.length===0">
            <td colspan="10" style="color:#9bbfeb">Ничего не найдено</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { supabase } from '../supabase'

const verticals = ['gambling', 'exchange', 'exchange bestchange', 'forex', 'betting', 'adult', 'mix']
const providerTypes = ['провайдер', 'прямой мерчант', 'агрегатор провайдер', 'агрегатор мерчант']

const filters = ref({
  vertical: '',
  provider_type: '',
  stakeMin: null,
  chekiMin: null,
  insurance: '',
  rolling_reserve: '',
  settlementQuery: ''
})
const items = ref([])
const loaded = ref(false)

function fmt(v){ if(v==null) return ''; const n = Number(v); return isFinite(n)? n : v }

function clearFilters(){
  filters.value = { vertical:'', provider_type:'', stakeMin:null, chekiMin:null, insurance:'', rolling_reserve:'', settlementQuery:'' }
  items.value = []
  loaded.value = false
}

async function load(){
  let q = supabase.from('offers').select('*').order('date', { ascending: false })

  if(filters.value.vertical) q = q.eq('vertical', filters.value.vertical)
  if(filters.value.provider_type) q = q.eq('provider_type', filters.value.provider_type)
  if(filters.value.insurance !== '') q = q.eq('insurance', filters.value.insurance === 'true')
  if(filters.value.rolling_reserve !== '') q = q.eq('rolling_reserve', filters.value.rolling_reserve === 'true')
  if(filters.value.stakeMin != null && filters.value.stakeMin !== '') q = q.gte('stake', Number(filters.value.stakeMin))
  if(filters.value.chekiMin != null && filters.value.chekiMin !== '') q = q.gte('cheki', Number(filters.value.chekiMin))
  if(filters.value.settlementQuery) q = q.ilike('settlement', `%${filters.value.settlementQuery}%`)

  const { data, error } = await q
  if(error){ console.error(error); items.value = []; loaded.value = true; return }
  items.value = data || []
  loaded.value = true
}
</script>
