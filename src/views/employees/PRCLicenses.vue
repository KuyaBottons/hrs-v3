<script setup>
import { ref, computed, onMounted } from 'vue'
import { useEmployeeStore } from '@/stores/employees'
import { usePermissions } from '@/composables/usePermissions'
import AppSelect from '@/components/AppSelect.vue'
import { API_ENDPOINTS } from '@/config/api'

const empStore = useEmployeeStore()
const { hasPermission, loadPermissions } = usePermissions()
const API = API_ENDPOINTS.PRC_LICENSES

onMounted(async () => {
  await loadPermissions()
  await fetchPRCLicenses()
  await empStore.fetchEmployees()
})

// ── Employee combobox ────────────────────────────────────────────────────────
const empSearch   = ref('')
const empDropOpen = ref(false)

const filteredEmps = computed(() => {
  const q = empSearch.value.toLowerCase().trim()
  if (!q) return empStore.employees

  return empStore.employees.filter(e =>
    e.lastName.toLowerCase().includes(q) ||
    e.firstName.toLowerCase().includes(q) ||
    e.employeeNo.toLowerCase().includes(q)
  )
})

function selectEmployee(emp) {
  form.value.employee_id = emp.id
  empSearch.value = `${emp.employeeNo} — ${emp.lastName}, ${emp.firstName}`
  empDropOpen.value = false
}

function onEmpSearchInput() {
  empDropOpen.value = true
  form.value.employee_id = ''
}

function onEmpBlur() {
  setTimeout(() => { empDropOpen.value = false }, 180)
}

// ── State ────────────────────────────────────────────────────────────────────
const prcLicenses = ref([])
const loading = ref(false)
const search = ref('')
const filterStatus = ref('')

// ── Form modal ───────────────────────────────────────────────────────────────
const showForm = ref(false)
const editId = ref(null)
const saving = ref(false)
const formErrors = ref({})

function blankForm() {
  return { employee_id: '', license_number: '', expiry_date: '', remarks: '' }
}
const form = ref(blankForm())

// ── Delete modal ───────────────────────────────────────────────────────────────
const showDeleteModal = ref(false)
const deleteTarget = ref(null)

// ── Icons ─────────────────────────────────────────────────────────────────────
const svgIcons = {
  search:  '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>',
  add:     '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>',
  edit:    '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>',
  delete:  '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>',
  warn:    '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/></svg>',
  close:   '<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>',
}

// ── Fetch PRC licenses ───────────────────────────────────────────────────────
async function fetchPRCLicenses() {
  loading.value = true
  try {
    const user = JSON.parse(sessionStorage.getItem('hris_user') || 'null')
    const headers = { 'Content-Type': 'application/json' }
    if (user?.id) headers['X-User-ID'] = String(user.id)

    const res = await fetch(API, { headers })
    const rows = await res.json()
    prcLicenses.value = Array.isArray(rows) ? rows : []
  } catch (e) {
    console.error('Failed to fetch PRC licenses:', e)
  } finally {
    loading.value = false
  }
}

// ── Filtered list ─────────────────────────────────────────────────────────────
const filtered = computed(() => {
  let list = prcLicenses.value.filter(license => {
    const q = search.value.toLowerCase()
    const matchSearch = !q || 
      license.license_number.toLowerCase().includes(q) ||
      license.first_name.toLowerCase().includes(q) ||
      license.last_name.toLowerCase().includes(q) ||
      license.position.toLowerCase().includes(q) ||
      license.department.toLowerCase().includes(q)
    
    const matchStatus = !filterStatus.value || checkLicenseStatus(license.expiry_date) === filterStatus.value
    return matchSearch && matchStatus
  })
  return list
})

// ── License status check ───────────────────────────────────────────────────────
function checkLicenseStatus(expiryDate) {
  if (!expiryDate) return 'Unknown'
  const today = new Date()
  const expiry = new Date(expiryDate)
  const diffDays = Math.ceil((expiry - today) / (1000 * 60 * 60 * 24))
  
  if (diffDays < 0) return 'Expired'
  if (diffDays <= 30) return 'Expiring Soon'
  return 'Active'
}

function statusClass(status) {
  return { 'Active': 'badge-green', 'Expiring Soon': 'badge-orange', 'Expired': 'badge-red', 'Unknown': 'badge-gray' }[status] || 'badge-gray'
}

// ── CRUD operations ───────────────────────────────────────────────────────────
function openAdd() {
  editId.value = null
  form.value = blankForm()
  formErrors.value = {}
  empSearch.value = ''
  empDropOpen.value = false
  showForm.value = true
}

function openEdit(license) {
  editId.value = license.id
  form.value = {
    employee_id: license.employee_id,
    license_number: license.license_number,
    expiry_date: license.expiry_date,
    remarks: license.remarks || ''
  }
  formErrors.value = {}
  
  // Set the employee search value based on selected employee
  const emp = empStore.employees.find(e => e.id === license.employee_id)
  if (emp) {
    empSearch.value = `${emp.employeeNo} — ${emp.lastName}, ${emp.firstName}`
  } else {
    empSearch.value = ''
  }
  empDropOpen.value = false
  showForm.value = true
}

async function save() {
  formErrors.value = {}
  if (!form.value.employee_id) { formErrors.value.employee_id = 'Required'; return }
  if (!form.value.license_number.trim()) { formErrors.value.license_number = 'Required'; return }
  if (!form.value.expiry_date) { formErrors.value.expiry_date = 'Required'; return }

  saving.value = true
  try {
    const user = JSON.parse(sessionStorage.getItem('hris_user') || 'null')
    const headers = { 'Content-Type': 'application/json' }
    if (user?.id) headers['X-User-ID'] = String(user.id)

    const url = editId.value ? `${API}?id=${editId.value}` : API
    const method = editId.value ? 'PUT' : 'POST'
    
    const res = await fetch(url, { method, headers, body: JSON.stringify(form.value) })
    const json = await res.json()
    if (!res.ok) throw new Error(json.error || 'Save failed')
    
    showForm.value = false
    await fetchPRCLicenses()
  } catch (e) {
    alert('Failed: ' + e.message)
  } finally {
    saving.value = false
  }
}

function promptDelete(license) {
  deleteTarget.value = {
    id: license.id,
    name: `${license.last_name}, ${license.first_name}`,
    licenseNumber: license.license_number,
    position: license.position || '—',
    department: license.department || '—'
  }
  showDeleteModal.value = true
}

function cancelDelete() {
  showDeleteModal.value = false
  deleteTarget.value = null
}

async function confirmDelete() {
  if (!deleteTarget.value) return
  try {
    const user = JSON.parse(sessionStorage.getItem('hris_user') || 'null')
    const headers = {}
    if (user?.id) headers['X-User-ID'] = String(user.id)

    const res = await fetch(`${API}?id=${deleteTarget.value.id}`, { method: 'DELETE', headers })
    const json = await res.json()
    if (!res.ok) throw new Error(json.error || 'Delete failed')
    
    await fetchPRCLicenses()
    cancelDelete()
  } catch (e) {
    alert('Failed to delete: ' + e.message)
  }
}

// ── Get employee name ─────────────────────────────────────────────────────────
function getEmployeeName(employeeId) {
  const emp = empStore.employees.find(e => e.id === employeeId)
  return emp ? `${emp.lastName}, ${emp.firstName}` : 'Unknown'
}
</script>

<template>
  <div class="page">

    <!-- ── Toolbar ─────────────────────────────────────────────────────────── -->
    <div class="toolbar">
      <div class="toolbar-left">
        <div class="search-wrap">
          <span class="icon-svg search-icon" v-html="svgIcons.search"></span>
          <input v-model="search" class="search-input" placeholder="Search by name, license number, position..." />
        </div>
        <AppSelect v-model="filterStatus" 
          :options="[{ label: 'All Status', value: '' }, { label: 'Active', value: 'Active' }, { label: 'Expiring Soon', value: 'Expiring Soon' }, { label: 'Expired', value: 'Expired' }]" 
          placeholder="All Status" />
      </div>
      <div class="toolbar-right">
        <span class="record-count">{{ filtered.length }} license(s)</span>
        <button v-if="hasPermission('PRC Licenses', 'Add')" class="btn btn-primary" @click="openAdd">
          <span class="icon-svg" v-html="svgIcons.add"></span> Add PRC License
        </button>
      </div>
    </div>

    <!-- ── Table ─────────────────────────────────────────────────────────────── -->
    <div class="table-wrapper">
      <table class="data-table">
        <thead>
          <tr>
            <th>Employee</th>
            <th>Position</th>
            <th>Department</th>
            <th>License Number</th>
            <th>Expiry Date</th>
            <th>Status</th>
            <th>Remarks</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="loading">
            <td colspan="8" class="empty-row">Loading...</td>
          </tr>
          <tr v-else-if="filtered.length === 0">
            <td colspan="8" class="empty-row">No PRC licenses found.</td>
          </tr>
          <tr v-for="license in filtered" :key="license.id">
            <td>
              <div class="emp-name-cell">
                <div class="emp-avatar">{{ license.first_name?.[0] }}{{ license.last_name?.[0] }}</div>
                <div>
                  <strong>{{ license.last_name }}, {{ license.first_name }}</strong>
                </div>
              </div>
            </td>
            <td>{{ license.position }}</td>
            <td>{{ license.department }}</td>
            <td><span class="license-no">{{ license.license_number }}</span></td>
            <td>{{ license.expiry_date }}</td>
            <td><span class="badge" :class="statusClass(checkLicenseStatus(license.expiry_date))">{{ checkLicenseStatus(license.expiry_date) }}</span></td>
            <td>{{ license.remarks || '—' }}</td>
            <td>
              <div class="action-btns">
                <button v-if="hasPermission('PRC Licenses', 'Edit')" class="btn-icon" title="Edit" @click="openEdit(license)">
                  <span class="icon-svg" v-html="svgIcons.edit"></span>
                </button>
                <button v-if="hasPermission('PRC Licenses', 'Delete')" class="btn-icon danger" title="Delete" @click="promptDelete(license)">
                  <span class="icon-svg" v-html="svgIcons.delete"></span>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- ── Add/Edit Modal ─────────────────────────────────────────────────────── -->
    <Transition name="modal">
      <div v-if="showForm" class="modal-overlay" @click.self="showForm = false">
        <div class="modal">
          <div class="modal-header">
            <h3>{{ editId ? 'Edit PRC License' : 'Add PRC License' }}</h3>
            <button class="close-btn" @click="showForm = false">
              <span class="icon-svg" v-html="svgIcons.close"></span>
            </button>
          </div>
          <div class="modal-body">
            <div class="form-grid">
              <div class="form-group full">
                <label>Employee <span class="req">*</span></label>
                <div class="emp-combobox">
                  <input
                    v-model="empSearch"
                    class="emp-search-input"
                    placeholder="Type name or employee no..."
                    @input="onEmpSearchInput"
                    @focus="empDropOpen = true"
                    @blur="onEmpBlur"
                    autocomplete="off"
                  />
                  <div v-if="empDropOpen && filteredEmps.length" class="emp-dropdown">
                    <div
                      v-for="emp in filteredEmps"
                      :key="emp.id"
                      class="emp-option"
                      @mousedown.prevent="selectEmployee(emp)"
                    >
                      <span class="emp-opt-no">{{ emp.employeeNo }}</span>
                      <span class="emp-opt-name">{{ emp.lastName }}, {{ emp.firstName }}</span>
                      <span class="emp-opt-dept">{{ emp.department }}</span>
                    </div>
                  </div>
                  <div v-if="empDropOpen && !filteredEmps.length" class="emp-dropdown">
                    <div class="emp-option-empty">No employees found.</div>
                  </div>
                </div>
                <span v-if="formErrors.employee_id" class="field-error">{{ formErrors.employee_id }}</span>
              </div>
              <div class="form-group full">
                <label>License Number <span class="req">*</span></label>
                <input v-model="form.license_number" placeholder="e.g. 123456" />
                <span v-if="formErrors.license_number" class="field-error">{{ formErrors.license_number }}</span>
              </div>
              <div class="form-group full">
                <label>Expiry Date <span class="req">*</span></label>
                <input v-model="form.expiry_date" type="date" />
                <span v-if="formErrors.expiry_date" class="field-error">{{ formErrors.expiry_date }}</span>
              </div>
              <div class="form-group full">
                <label>Remarks</label>
                <textarea v-model="form.remarks" rows="3" placeholder="Additional notes..."></textarea>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-secondary" @click="showForm = false" :disabled="saving">Cancel</button>
            <button class="btn btn-primary" @click="save" :disabled="saving">
              {{ saving ? 'Saving...' : 'Save' }}
            </button>
          </div>
        </div>
      </div>
    </Transition>

    <!-- ── Delete Confirmation Modal ─────────────────────────────────────────── -->
    <Transition name="modal">
      <div v-if="showDeleteModal" class="modal-overlay" @click.self="cancelDelete">
        <div class="modal">
          <div class="modal-icon-wrap">
            <span class="modal-icon" v-html="svgIcons.warn"></span>
          </div>
          <h3 class="modal-title">Delete PRC License</h3>
          <p class="modal-message">Are you sure you want to delete this PRC license?</p>
          <div class="modal-employee-card">
            <div class="modal-emp-avatar">
              {{ deleteTarget?.name?.split(',')[1]?.trim()[0] }}{{ deleteTarget?.name?.split(',')[0]?.trim()[0] }}
            </div>
            <div class="modal-emp-info">
              <strong>{{ deleteTarget?.name }}</strong>
              <span>{{ deleteTarget?.licenseNumber }} &bull; {{ deleteTarget?.position }} &bull; {{ deleteTarget?.department }}</span>
            </div>
          </div>
          <p class="modal-warning">This action cannot be undone.</p>
          <div class="modal-actions">
            <button class="btn btn-cancel" @click="cancelDelete">Cancel</button>
            <button class="btn btn-delete" @click="confirmDelete">
              <span class="icon-svg" v-html="svgIcons.delete"></span> Yes, Delete
            </button>
          </div>
        </div>
      </div>
    </Transition>

  </div>
</template>

<style scoped>
.icon-svg { display:inline-flex; align-items:center; justify-content:center; width:18px; height:18px; }
.icon-svg :deep(svg) { width:100%; height:100%; fill:currentColor; }
.page { padding: 24px; }

/* Toolbar */
.toolbar { position:sticky; top:0; z-index:10; background:#f0f4f8; padding:10px 0; display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:16px; flex-wrap:wrap; }
.toolbar-left, .toolbar-right { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.search-wrap { position:relative; display:inline-flex; align-items:center; }
.search-icon { position:absolute; left:10px; color:#aaa; pointer-events:none; }
.search-input { padding:8px 14px 8px 34px; border:1px solid #ddd; border-radius:8px; font-size:13px; width:300px; outline:none; }
.record-count { font-size:13px; color:#888; }
.btn { padding:8px 16px; border-radius:8px; border:none; cursor:pointer; font-size:13px; font-weight:600; text-decoration:none; display:inline-flex; align-items:center; gap:6px; }
.btn-primary { background:#1a3a5c; color:#fff; }
.btn-primary:hover { background:#2980b9; }
.btn-secondary { background:#f0f4f8; color:#1a3a5c; border:1px solid #ddd; }
.btn-secondary:hover { background:#e0e8f0; }

/* Table */
.table-wrapper { overflow-x:auto; overflow-y:auto; max-height:calc(100vh - 180px); background:#fff; border-radius:12px; box-shadow:0 2px 12px rgba(0,0,0,0.07); }
.data-table { width:100%; border-collapse:separate; border-spacing:0; font-size:13px; }
.data-table thead tr { background:#1a3a5c; color:#fff; }
.data-table thead tr th { position:sticky; top:0; z-index:2; background:#1a3a5c; }
.data-table th { padding:12px 14px; text-align:left; font-weight:600; white-space:nowrap; }
.data-table td { padding:10px 14px; border-bottom:1px solid #f0f4f8; vertical-align:middle; }
.data-table tbody tr:hover { background:#f9fafb; }
.emp-name-cell { display:flex; align-items:center; gap:10px; }
.emp-avatar { width:32px; height:32px; border-radius:50%; background:linear-gradient(135deg,#1a3a5c,#2980b9); color:#fff; display:flex; align-items:center; justify-content:center; font-size:11px; font-weight:700; flex-shrink:0; }
.license-no { font-family:monospace; font-size:12px; color:#1a3a5c; font-weight:600; }
.badge { padding:3px 10px; border-radius:12px; font-size:11px; font-weight:600; }
.badge-green  { background:#eafaf1; color:#27ae60; }
.badge-blue   { background:#ebf5fb; color:#2980b9; }
.badge-orange { background:#fef3e2; color:#e67e22; }
.badge-red    { background:#fdecea; color:#c0392b; }
.badge-gray   { background:#f4f4f4; color:#666; }
.action-btns { display:flex; gap:4px; }
.btn-icon { background:none; border:none; cursor:pointer; padding:4px; border-radius:4px; transition:background 0.2s; display:inline-flex; align-items:center; }
.btn-icon:hover { background:#f0f4f8; }
.btn-icon.danger:hover { background:#fdecea; color:#e74c3c; }
.empty-row { text-align:center; color:#aaa; padding:40px; }

/* Modal */
.modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,0.45); display:flex; align-items:center; justify-content:center; z-index:1000; backdrop-filter:blur(2px); }
.modal { background:#fff; border-radius:16px; padding:32px 28px 24px; width:100%; max-width:500px; box-shadow:0 20px 60px rgba(0,0,0,0.2); display:flex; flex-direction:column; gap:16px; }
.modal-header { display:flex; align-items:center; justify-content:space-between; gap:16px; }
.modal-header h3 { margin:0; font-size:18px; font-weight:700; color:#1a3a5c; }
.close-btn { background:none; border:none; cursor:pointer; padding:4px; border-radius:4px; display:inline-flex; align-items:center; }
.close-btn:hover { background:#f0f4f8; }
.modal-body { display:flex; flex-direction:column; gap:16px; }
.form-grid { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
.form-group.full { grid-column:1/-1; }
.form-group { display:flex; flex-direction:column; gap:6px; }
.form-group label { font-size:13px; font-weight:600; color:#1a1a2e; }
.form-group input, .form-group select, .form-group textarea { padding:10px 12px; border:1px solid #ddd; border-radius:8px; font-size:13px; outline:none; }
.form-group input:focus, .form-group select:focus, .form-group textarea:focus { border-color:#1a3a5c; }
.form-select { padding:10px 12px; border:1px solid #ddd; border-radius:8px; font-size:13px; outline:none; background:#fff; }
.req { color:#e74c3c; }
.field-error { font-size:11px; color:#e74c3c; }
.modal-footer { display:flex; gap:10px; justify-content:flex-end; }

/* Employee combobox */
.emp-combobox { position:relative; }
.emp-search-input { width:100%; padding:10px 12px; border:1px solid #ddd; border-radius:8px; font-size:13px; outline:none; box-sizing:border-box; }
.emp-search-input:focus { border-color:#1a3a5c; }
.emp-dropdown { position:absolute; top:calc(100% + 4px); left:0; right:0; background:#fff; border:1px solid #ddd; border-radius:8px; box-shadow:0 8px 24px rgba(0,0,0,0.12); z-index:9999; max-height:220px; overflow-y:auto; }
.emp-option { display:flex; align-items:center; gap:10px; padding:8px 12px; cursor:pointer; transition:background 0.15s; border-bottom:1px solid #f5f5f5; }
.emp-option:last-child { border-bottom:none; }
.emp-option:hover { background:#f0f9f4; }
.emp-opt-no { font-family:monospace; font-size:11px; color:#888; flex-shrink:0; min-width:90px; }
.emp-opt-name { font-size:13px; font-weight:600; color:#1a1a2e; flex:1; }
.emp-opt-dept { font-size:11px; color:#aaa; flex-shrink:0; }
.emp-option-empty { padding:12px; text-align:center; color:#aaa; font-size:13px; }

/* Delete Modal */
.modal-icon-wrap { width:56px; height:56px; border-radius:50%; background:#fef3e2; display:flex; align-items:center; justify-content:center; }
.modal-icon { width:28px; height:28px; color:#e67e22; }
.modal-icon :deep(svg) { width:28px; height:28px; fill:#e67e22; }
.modal-title { margin:0; font-size:18px; font-weight:700; color:#1a1a2e; display:flex; align-items:center; gap:8px; }
.modal-message { margin:0; font-size:14px; color:#555; }
.modal-employee-card { display:flex; align-items:center; gap:12px; background:#f8f9fa; border:1px solid #e9ecef; border-radius:10px; padding:12px 16px; width:100%; text-align:left; }
.modal-emp-avatar { width:40px; height:40px; border-radius:50%; background:linear-gradient(135deg,#c0392b,#e74c3c); color:#fff; display:flex; align-items:center; justify-content:center; font-size:13px; font-weight:700; flex-shrink:0; }
.modal-emp-info { display:flex; flex-direction:column; gap:2px; }
.modal-emp-info strong { font-size:14px; color:#1a1a2e; }
.modal-emp-info span { font-size:12px; color:#888; }
.modal-warning { margin:0; font-size:12px; color:#e74c3c; font-weight:600; }
.modal-actions { display:flex; gap:10px; width:100%; margin-top:4px; }
.btn-cancel { flex:1; padding:10px; border-radius:8px; background:#f0f4f8; color:#555; border:1px solid #ddd; font-size:13px; font-weight:600; cursor:pointer; }
.btn-cancel:hover { background:#e0e8f0; }
.btn-delete { flex:1; padding:10px; border-radius:8px; background:#e74c3c; color:#fff; border:none; font-size:13px; font-weight:600; cursor:pointer; display:inline-flex; align-items:center; justify-content:center; gap:6px; }
.btn-delete:hover { background:#c0392b; }
.btn-delete .icon-svg :deep(svg) { fill:#fff; }

/* Modal transition */
.modal-enter-active, .modal-leave-active { transition:opacity 0.2s ease; }
.modal-enter-active .modal, .modal-leave-active .modal { transition:transform 0.2s ease, opacity 0.2s ease; }
.modal-enter-from, .modal-leave-to { opacity:0; }
.modal-enter-from .modal, .modal-leave-to .modal { transform:scale(0.95); opacity:0; }
</style>
