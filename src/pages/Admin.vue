<template>
  <div class="container">
    <div v-if="!isAdmin" class="card" style="max-width:420px;margin:40px auto">
      <h2 style="margin-top:0">Вход в админ-панель</h2>
      <p style="color:#9bbfeb">Авторизация действует до закрытия вкладки.</p>
      <label class="label">Пароль</label>
      <input v-model="password" type="password" class="input" placeholder="Введите пароль" @keyup.enter="login" />
      <div style="margin-top:12px;display:flex;gap:8px">
        <button class="btn btn-primary" @click="login">Войти</button>
        <button class="btn" @click="$router.push('/')">Отмена</button>
      </div>
      <p v-if="err" style="color:#ff9d9d;margin-top:8px">{{ err }}</p>
    </div>

    <div v-else class="grid" style="gap:16px">
      <div class="card">
        <h2 style="margin:0 0 12px 0">Добавить / Редактировать оффер</h2>
        <div class="grid grid-3">
          <div>
            <label class="label">Дата</label>
            <input v-model="form.date" type="date" class="input" />
          </div>

          <div>
            <label class="label">Вертикаль</label>
            <select v-model="form.vertical" class="select">
              <option v-for="v in verticals" :key="v" :value="v">{{ v }}</option>
            </select>
          </div>

          <div>
            <label class="label">Тип провайдера</label>
            <select v-model="form.provider_type" class="select">
              <option v-for="t in providerTypes" :key="t" :value="t">{{ t }}</option>
            </select>
          </div>

          <div>
            <label class="label">Ставка, %</label>
            <input v-model.number="form.stake" type="number" step="0.01" min="0" class="input" placeholder="например, 3" />
          </div>

          <div>
            <label class="label">Чеки</label>
            <input v-model.number="form.cheki" type="number" step="0.01" min="0" class="input" placeholder="например, 1000" />
          </div>

          <div>
            <label class="label">Страховой</label>
            <select v-model="form.insurance" class="select">
              <option :value="true">Да</option>
              <option :value="false">Нет</option>
            </select>
          </div>

          <div>
            <label class="label">Роллинг-резерв</label>
            <select v-model="form.rolling_reserve" class="select">
              <option :value="true">Да</option>
              <option :value="false">Нет</option>
            </select>
          </div>

          <div>
            <label class="label">Сеттлмент</label>
            <input v-model="form.settlement" type="text" class="input" placeholder="например, T+3" />
          </div>

          <div>
            <label class="label">Внутренний ID (необязательно)</label>
            <input v-model.number="form.internal_id" type="number" min="1" class="input" placeholder="оставьте пустым для авто" />
          </div>
        </div>

        <div style="margin-top:12px;display:flex;gap:8px;flex-wrap:wrap">
          <button class="btn btn-primary" @click="save">Сохранить</button>
          <button class="btn" @click="reset">Очистить</button>
          <span v-if="msg" class="kbd">{{ msg }}</span>
          <span v-if="saveError" style="color:#ff9d9d">{{ saveError }}</span>
        </div>
      </div>

      <div class="card">
        <h3 style="margin:0 0 8px 0">Офферы (кликни по строке для редактирования)</h3>
        <table class="table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Внутр. ID</th>
              <th>Дата</th>
              <th>Вертикаль</th>
              <th>Тип провайдера</th>
              <th>Ставка%</th>
              <th>Чеки</th>
              <th>Страховой</th>
              <th>Роллинг</th>
              <th>Сеттлмент</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="o in items" :key="o.id" @click="edit(o)" style="cursor:pointer">
              <td>{{ o.id }}</td>
              <td>{{ o.internal_id }}</td>
              <td>{{ o.date }}</td>
              <td>{{ o.vertical }}</td>
              <td>{{ o.provider_type }}</td>
              <td>{{ o.stake }}</td>
              <td>{{ o.cheki }}</td>
              <td>{{ o.insurance ? 'Да':'Нет' }}</td>
              <td>{{ o.rolling_reserve ? 'Да':'Нет' }}</td>
              <td>{{ o.settlement }}</td>
              <td><button class="btn btn-danger" @click.stop="remove(o)">Удалить</button></td>
            </tr>
            <tr v-if="items.length===0">
              <td colspan="11" style="color:#9bbfeb">Записей нет</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { supabase } from '../supabase'

const verticals = ['gambling', 'exchange', 'exchange bestchange', 'forex', 'betting', 'adult', 'mix']
const providerTypes = ['провайдер', 'прямой мерчант', 'агрегатор провайдер', 'агрегатор мерчант']

const password = ref('')
const err = ref('')

const isAdmin = ref(sessionStorage.getItem('isAdmin') === '1')

function login(){
  if(password.value === 'admin23'){
    sessionStorage.setItem('isAdmin', '1')
    isAdmin.value = true
    err.value = ''
    load()
  }else{
    err.value = 'Доступ ограничен'
  }
}

const form = ref({
  id: null,
  date: '',
  vertical: 'gambling',
  provider_type: 'провайдер',
  stake: null,
  cheki: null,
  insurance: false,
  rolling_reserve: false,
  settlement: '',
  internal_id: null
})

const items = ref([])
const msg = ref('')
const saveError = ref('')

function reset(){
  form.value = {
    id:null, date:'', vertical:'gambling', provider_type:'провайдер',
    stake:null, cheki:null, insurance:false, rolling_reserve:false,
    settlement:'', internal_id: null
  }
  msg.value = ''
  saveError.value = ''
}

function edit(o){
  form.value = { ...o }
  if(!o.internal_id) form.value.internal_id = null
  msg.value = 'Редактирование'
}

async function load(){
  const { data, error } = await supabase.from('offers').select('*').order('date', { ascending:false })
  if(error){ console.error(error); return }
  items.value = data || []
}

async function save(){
  saveError.value = ''
  msg.value = ''
  try{
    const payload = {
      date: form.value.date || null,
      vertical: form.value.vertical || null,
      provider_type: form.value.provider_type || null,
      stake: form.value.stake!=null? Number(form.value.stake) : null,
      cheki: form.value.cheki!=null? Number(form.value.cheki) : null,
      insurance: !!form.value.insurance,
      rolling_reserve: !!form.value.rolling_reserve,
      settlement: form.value.settlement || null
    }
    if(form.value.internal_id != null && form.value.internal_id !== ''){
      payload.internal_id = Number(form.value.internal_id)
    }

    if(form.value.id){
      const { error } = await supabase.from('offers').update(payload).eq('id', form.value.id)
      if(error) throw error
      msg.value = 'Сохранено'
    }else{
      const { error } = await supabase.from('offers').insert(payload)
      if(error) throw error
      msg.value = 'Добавлено'
    }
    reset()
    await load()
  }catch(e){
    console.error(e)
    saveError.value = e.message || 'Ошибка сохранения'
  }
}

async function remove(o){
  try{
    const { error } = await supabase.from('offers').delete().eq('id', o.id)
    if(error) throw error
    await load()
  }catch(e){
    console.error(e)
    alert('Ошибка удаления: ' + (e.message||e))
  }
}

onMounted(()=>{ if(isAdmin.value) load() })
</script>
