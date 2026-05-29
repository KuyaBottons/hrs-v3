<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useLeaveStore } from '@/stores/leave'
import { useEmployeeStore } from '@/stores/employees'
import { usePermissions } from '@/composables/usePermissions'
import AppModal from '@/components/AppModal.vue'
import { printLeaveRecords } from '@/utils/print'

const store = useLeaveStore()
const employeeStore = useEmployeeStore()
const { hasPermission, loadPermissions } = usePermissions()

// Fetch leave records when component mounts
onMounted(async () => {
  await loadPermissions()
  store.fetchRecords()
  document.addEventListener('mousedown', handleClickOutside)
})

onBeforeUnmount(() => {
  document.removeEventListener('mousedown', handleClickOutside)
})

const employeeDropdownRef = ref(null)

function handleClickOutside(e) {
  if (employeeDropdownRef.value && !employeeDropdownRef.value.contains(e.target)) {
    showEmployeeDropdown.value = false
  }
}

const svgIcons = {
  search: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>`,
  add:    `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>`,
  edit:   `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>`,
  delete: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>`,
  save:   `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M17 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V7l-4-4zm-5 16c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3zm3-10H5V5h10v4z"/></svg>`,
  close:  `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>`,
}

const search = ref('')
const filterType = ref('')
const filterStatus = ref('')
const filterDateFrom = ref('')
const filterDateTo = ref('')
const sortBy = ref('dateFrom')
const sortOrder = ref('desc')
const activeTab = ref('list')
const showForm = ref(false)
const editId = ref(null)

// ── Employee Report Modal ─────────────────────────────────────────────────────
const showReportModal = ref(false)
const reportEmployee  = ref(null)

function openEmployeeReport(r) {
  reportEmployee.value = {
    employeeId:   r.employeeId,
    employeeName: r.employeeName,
    employeeNo:   r.employeeNo,
    department:   r.department,
  }
  showReportModal.value = true
}

const employeeLeaveRecords = computed(() => {
  if (!reportEmployee.value) return []
  return store.leaveRecords.filter(r => r.employeeId === reportEmployee.value.employeeId)
})

const employeeLeaveSummary = computed(() => {
  const totals = {}
  for (const r of employeeLeaveRecords.value) {
    if (!totals[r.leaveType]) totals[r.leaveType] = { total: 0, approved: 0, pending: 0, disapproved: 0 }
    totals[r.leaveType].total      += Number(r.days) || 0
    const key = r.status?.toLowerCase()
    if (key === 'approved')    totals[r.leaveType].approved    += Number(r.days) || 0
    if (key === 'pending')     totals[r.leaveType].pending     += Number(r.days) || 0
    if (key === 'disapproved') totals[r.leaveType].disapproved += Number(r.days) || 0
  }
  return totals
})

// ── AppModal state ────────────────────────────────────────────────────────────
const showDeleteModal = ref(false)
const showSaveModal   = ref(false)
const deleteTarget    = ref(null)

function promptDelete(id) {
  deleteTarget.value = store.leaveRecords.find(r => r.id === id)
  showDeleteModal.value = true
}
function confirmDelete() {
  if (deleteTarget.value) store.deleteRecord(deleteTarget.value.id)
  showDeleteModal.value = false
  deleteTarget.value = null
}

const blankForm = () => ({
  employeeId: null, employeeNo: '', employeeName: '', department: '',
  leaveType: 'Vacation Leave', dateFrom: '', dateTo: '', days: 1,
  reason: '', status: 'Pending', approvedBy: '', dateApproved: '', remarks: '',
})
const form = ref(blankForm())
const formErrors = ref({ employeeId: '' })

// Employee dropdown state
const showEmployeeDropdown = ref(false)
const employeeSearch = ref('')

const filteredEmployees = computed(() => {
  const query = employeeSearch.value.toLowerCase()
  if (!query) return employeeStore.employees.slice(0, 50) // Show first 50 if no search
  return employeeStore.employees.filter(emp => {
    const fullName = `${emp.lastName}, ${emp.firstName} ${emp.middleName ? emp.middleName.charAt(0) + '.' : ''}`.toLowerCase()
    const empNo = emp.employeeNo.toLowerCase()
    return fullName.includes(query) || empNo.includes(query)
  }).slice(0, 50)
})

function selectEmployee(emp) {
  form.value.employeeId = emp.id
  form.value.employeeNo = emp.employeeNo
  form.value.employeeName = `${emp.lastName}, ${emp.firstName}${emp.middleName ? ' ' + emp.middleName.charAt(0) + '.' : ''}`.trim()
  form.value.department = emp.department
  employeeSearch.value = form.value.employeeName
  showEmployeeDropdown.value = false
  formErrors.value.employeeId = ''
}

function clearEmployeeSelection() {
  form.value.employeeId = null
  form.value.employeeNo = ''
  form.value.employeeName = ''
  form.value.department = ''
  employeeSearch.value = ''
}

function openAdd() {
  editId.value = null
  form.value = blankForm()
  formErrors.value = { employeeId: '' }
  employeeSearch.value = ''
  showForm.value = true
}
function openEdit(rec) {
  editId.value = rec.id
  form.value = { ...rec }
  formErrors.value = { employeeId: '' }
  employeeSearch.value = rec.employeeName
  showForm.value = true
}

function save() {
  formErrors.value = { employeeId: '' }
  let valid = true
  if (!form.value.employeeId) { 
    formErrors.value.employeeId = 'Please select an employee from the list.'
    valid = false 
  }
  if (!valid) return
  showSaveModal.value = true
}
function confirmSave() {
  if (editId.value) store.updateRecord(editId.value, { ...form.value })
  else store.addRecord({ ...form.value })
  showSaveModal.value = false
  showForm.value = false
}

const filtered = computed(() => {
  let list = store.leaveRecords.filter(r => {
    const q = search.value.toLowerCase()
    const matchSearch = !q || r.employeeName.toLowerCase().includes(q)
    const matchType   = !filterType.value   || r.leaveType === filterType.value
    const matchStatus = !filterStatus.value || r.status    === filterStatus.value
    
    // Date range filtering
    let matchDateRange = true
    if (filterDateFrom.value && r.dateFrom < filterDateFrom.value) matchDateRange = false
    if (filterDateTo.value && r.dateTo > filterDateTo.value) matchDateRange = false
    
    return matchSearch && matchType && matchStatus && matchDateRange
  })
  
  // Sort by selected field
  list.sort((a, b) => {
    const aVal = a[sortBy.value] || ''
    const bVal = b[sortBy.value] || ''
    const comparison = aVal.localeCompare(bVal, undefined, { numeric: true, sensitivity: 'base' })
    return sortOrder.value === 'asc' ? comparison : -comparison
  })
  
  return list
})

function statusClass(s) {
  return { Pending: 'badge-orange', Approved: 'badge-green', Disapproved: 'badge-red', Cancelled: 'badge-gray' }[s] || 'badge-gray'
}
</script>

<template>
  <div class="page">
    <!-- Loading State -->
    <div v-if="store.loading" class="loading-overlay">
      <div class="spinner"></div>
      <p>Loading leave records...</p>
    </div>

    <!-- Error State -->
    <div v-if="store.error" class="error-banner">
      <strong>Error:</strong> {{ store.error }}
      <button class="btn-retry" @click="store.fetchRecords()">Retry</button>
    </div>

    <!-- Tabs -->
    <div class="tabs">
      <button class="tab-btn" :class="{ active: activeTab === 'list' }" @click="activeTab = 'list'">
        <span class="icon-svg" v-html="svgIcons.search"></span> List
      </button>
      <button class="tab-btn" :class="{ active: activeTab === 'summary' }" @click="activeTab = 'summary'">
        <span class="icon-svg" v-html="svgIcons.save"></span> Summary Report
      </button>
    </div>

    <div class="toolbar">
      <div class="toolbar-left">
        <div class="search-wrap">
          <span class="icon-svg search-icon" v-html="svgIcons.search"></span>
          <input v-model="search" class="search-input" placeholder="Search employee..." />
        </div>
        <AppSelect v-model="filterType"   :options="[{ label: 'All Leave Types', value: '' }, ...store.leaveTypes.map(t => ({ label: t, value: t }))]" placeholder="All Leave Types" />
        <AppSelect v-model="filterStatus" :options="[{ label: 'All Status', value: '' }, ...store.statuses.map(s => ({ label: s, value: s }))]" placeholder="All Status" />
        <input v-model="filterDateFrom" type="date" class="date-input" placeholder="Date From" />
        <AppSelect v-model="sortBy" :options="[{ value: 'dateFrom', label: 'Date From' }, { value: 'dateTo', label: 'Date To' }, { value: 'employeeName', label: 'Employee Name' }]" placeholder="Sort By" />
        <button class="btn btn-secondary" @click="sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'">
          {{ sortOrder.value === 'asc' ? 'A-Z' : 'Z-A' }}
        </button>
      </div>
      <div class="toolbar-right">
        <span class="record-count">{{ filtered.length }} record(s)</span>
        <button class="btn btn-secondary" @click="printLeaveRecords(filtered, { Type: filterType, Status: filterStatus })">
          🖨 Print
        </button>
        <button v-if="hasPermission('Leave Management', 'Add')" class="btn btn-primary" @click="openAdd">
          <span class="icon-svg" v-html="svgIcons.add"></span> Add Leave
        </button>
      </div>
    </div>

    <div class="table-wrapper" v-if="activeTab === 'list'">
      <table class="data-table">
        <thead>
          <tr>
            <th>Employee</th><th>Department</th><th>Leave Type</th>
            <th>Date From</th><th>Date To</th><th>Days</th>
            <th>Reason</th><th>Status</th><th>Approved By</th><th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="filtered.length === 0"><td colspan="10" class="empty-row">No leave records found.</td></tr>
          <tr v-for="r in filtered" :key="r.id">
            <td>
              <span class="doc-type clickable" @click="openEmployeeReport(r)" :title="'View ' + r.employeeName + ' individual report'">{{ r.employeeName }}</span>
              <div class="sub-text">{{ r.employeeNo }}</div>
            </td>
            <td>{{ r.department }}</td>
            <td><span class="leave-type">{{ r.leaveType }}</span></td>
            <td>{{ r.dateFrom }}</td><td>{{ r.dateTo }}</td>
            <td class="days-cell">{{ r.days }}</td>
            <td class="reason-cell">{{ r.reason }}</td>
            <td><span class="badge" :class="statusClass(r.status)">{{ r.status }}</span></td>
            <td v-if="r.status !== 'Disapproved'">{{ r.approvedBy || '—' }}</td>
            <td v-if="r.status === 'Disapproved'">—</td>
            <td>
              <div class="action-btns">
                <button v-if="hasPermission('Leave Management', 'Edit')" class="btn-icon" @click="openEdit(r)"><span class="icon-svg" v-html="svgIcons.edit"></span></button>
                <button v-if="hasPermission('Leave Management', 'Delete')" class="btn-icon danger" @click="promptDelete(r.id)"><span class="icon-svg" v-html="svgIcons.delete"></span></button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Summary Report View -->
    <div v-if="activeTab === 'summary'" class="report-view">
      <div v-if="store.leaveRecords.length === 0" class="empty-state">
        <p>No leave records found.</p>
      </div>
      <div v-else class="report-grid">
        <div v-for="r in store.leaveRecords" :key="r.id" class="summary-card">
          <div class="card-header">
            <div class="card-title">
              <span class="icon-svg" v-html="svgIcons.save"></span>
              <span class="action-badge">Leave Request</span>
            </div>
            <span class="badge" :class="statusClass(r.status)">{{ r.status }}</span>
          </div>
          <div class="card-body">
            <div class="card-row">
              <span class="card-label">Employee:</span>
              <span class="card-value">{{ r.employeeName }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Emp No:</span>
              <span class="card-value emp-no">{{ r.employeeNo }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Department:</span>
              <span class="card-value">{{ r.department }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Leave Type:</span>
              <span class="card-value">{{ r.leaveType }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Date From:</span>
              <span class="card-value">{{ r.dateFrom }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Date To:</span>
              <span class="card-value">{{ r.dateTo }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Days:</span>
              <span class="card-value">{{ r.days }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Approved By:</span>
              <span class="card-value">{{ r.approvedBy || '—' }}</span>
            </div>
            <div class="card-row full-width">
              <span class="card-label">Reason:</span>
              <span class="card-value remarks">{{ r.reason || 'NA' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Form Modal -->
    <Transition name="modal-fade">
    <div v-if="showForm" class="modal-overlay modal-overlay-blur" @click.self="showForm = false">
      <div class="modal modal-animated">
        <div class="modal-header">
          <h3>{{ editId ? 'Edit Leave Record' : 'Add Leave Request' }}</h3>
          <button class="close-btn" @click="showForm = false"><span class="icon-svg" v-html="svgIcons.close"></span></button>
        </div>
        <div class="modal-body">
          <div class="form-grid">
            <div class="form-group full employee-selector" ref="employeeDropdownRef">
              <label>Select Employee</label>
              <div class="employee-input-wrapper">
                <input 
                  v-model="employeeSearch" 
                  @focus="showEmployeeDropdown = true"
                  @input="showEmployeeDropdown = true"
                  placeholder="Search by name or employee number..." 
                  class="employee-search-input"
                  autocomplete="off"
                />
                <button 
                  v-if="form.employeeId" 
                  type="button" 
                  class="clear-employee-btn" 
                  @click="clearEmployeeSelection"
                  title="Clear selection"
                >
                  <span class="icon-svg" v-html="svgIcons.close"></span>
                </button>
              </div>
              <span v-if="formErrors.employeeId" class="field-error">{{ formErrors.employeeId }}</span>
              
              <div v-if="showEmployeeDropdown && filteredEmployees.length > 0" class="employee-dropdown">
                <div 
                  v-for="emp in filteredEmployees" 
                  :key="emp.id"
                  class="employee-option"
                  :class="{ selected: emp.id === form.employeeId }"
                  @mousedown.prevent="selectEmployee(emp)"
                >
                  <div class="employee-option-main">
                    <strong>{{ emp.lastName }}, {{ emp.firstName }}{{ emp.middleName ? ' ' + emp.middleName.charAt(0) + '.' : '' }}</strong>
                    <span class="employee-option-no">{{ emp.employeeNo }}</span>
                  </div>
                  <div class="employee-option-dept">{{ emp.department }} • {{ emp.position }}</div>
                </div>
              </div>
              <div v-else-if="showEmployeeDropdown && employeeSearch && filteredEmployees.length === 0" class="employee-dropdown-empty">
                No employees found matching "{{ employeeSearch }}"
              </div>
            </div>

            <div class="form-group">
              <label>Employee No.</label>
              <input v-model="form.employeeNo" readonly disabled placeholder="Auto-filled" />
            </div>
            <div class="form-group">
              <label>Employee Name</label>
              <input v-model="form.employeeName" readonly disabled placeholder="Auto-filled" />
            </div>
            <div class="form-group">
              <label>Department</label>
              <input v-model="form.department" readonly disabled placeholder="Auto-filled" />
            </div>
            <div class="form-group"><label>Leave Type</label><AppSelect v-model="form.leaveType" :options="store.leaveTypes" /></div>
            <div class="form-group"><label>Date From</label><input v-model="form.dateFrom" type="date" /></div>
            <div class="form-group"><label>Date To</label><input v-model="form.dateTo" type="date" /></div>
            <div class="form-group"><label>No. of Days</label><input v-model.number="form.days" type="number" min="1" /></div>
            <div class="form-group"><label>Status</label><AppSelect v-model="form.status" :options="store.statuses" /></div>
            <div class="form-group"><label>Approved By</label><input v-model="form.approvedBy" /></div>
            <div class="form-group"><label>Date Approved</label><input v-model="form.dateApproved" type="date" /></div>
            <div class="form-group full"><label>Reason</label><textarea v-model="form.reason" rows="2"></textarea></div>
            <div class="form-group full"><label>Remarks</label><textarea v-model="form.remarks" rows="2"></textarea></div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showForm = false">Cancel</button>
          <button class="btn btn-primary" @click="save"><span class="icon-svg" v-html="svgIcons.save"></span> Save</button>
        </div>
      </div>
    </div>
    </Transition>

    <!-- Employee Individual Report Modal -->
    <Transition name="modal-fade">
    <div v-if="showReportModal" class="modal-overlay modal-overlay-blur" @click.self="showReportModal = false">
      <div class="modal modal-report">
        <div class="modal-header report-modal-header">
          <div class="report-header-info">
            <div class="report-avatar">{{ reportEmployee?.employeeName?.charAt(0) }}</div>
            <div>
              <h3>{{ reportEmployee?.employeeName }}</h3>
              <div class="report-meta">
                <span class="report-empno">{{ reportEmployee?.employeeNo }}</span>
                <span class="report-dept">{{ reportEmployee?.department }}</span>
              </div>
            </div>
          </div>
          <button class="close-btn" @click="showReportModal = false"><span class="icon-svg" v-html="svgIcons.close"></span></button>
        </div>

        <div class="modal-body">
          <!-- Leave Summary by Type -->
          <div class="report-section">
            <h4 class="report-section-title">Leave Summary</h4>
            <div v-if="Object.keys(employeeLeaveSummary).length === 0" class="report-empty">No leave records found.</div>
            <div v-else class="summary-chips">
              <div v-for="(data, type) in employeeLeaveSummary" :key="type" class="summary-chip">
                <div class="chip-type">{{ type }}</div>
                <div class="chip-stats">
                  <span class="chip-total">{{ data.total }}</span>
                  <span class="chip-unit">day{{ data.total !== 1 ? 's' : '' }}</span>
                  <span v-if="data.approved"    class="chip-badge chip-approved">{{ data.approved }}d approved</span>
                  <span v-if="data.pending"     class="chip-badge chip-pending">{{ data.pending }}d pending</span>
                  <span v-if="data.disapproved" class="chip-badge chip-disapproved">{{ data.disapproved }}d disapproved</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Detailed Leave Records -->
          <div class="report-section">
            <h4 class="report-section-title">Leave Records <span class="report-count">{{ employeeLeaveRecords.length }}</span></h4>
            <div v-if="employeeLeaveRecords.length === 0" class="report-empty">No leave records found.</div>
            <div v-else class="report-records">
              <div v-for="rec in employeeLeaveRecords" :key="rec.id" class="report-record-card">
                <div class="rrc-top">
                  <span class="rrc-type">{{ rec.leaveType }}</span>
                  <span class="badge" :class="statusClass(rec.status)">{{ rec.status }}</span>
                </div>
                <div class="rrc-dates">
                  <span class="rrc-date-label">From</span>
                  <span class="rrc-date">{{ rec.dateFrom }}</span>
                  <span class="rrc-date-sep">→</span>
                  <span class="rrc-date-label">To</span>
                  <span class="rrc-date">{{ rec.dateTo }}</span>
                  <span class="rrc-days">{{ rec.days }} day{{ rec.days !== 1 ? 's' : '' }}</span>
                </div>
                <div v-if="rec.reason" class="rrc-reason">{{ rec.reason }}</div>
                <div v-if="rec.approvedBy" class="rrc-approved">
                  <span class="rrc-approved-label">Approved by:</span> {{ rec.approvedBy }}
                  <span v-if="rec.dateApproved"> on {{ rec.dateApproved }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showReportModal = false">Close</button>
          <button class="btn btn-primary" @click="printLeaveRecords(employeeLeaveRecords, { Employee: reportEmployee?.employeeName })">
            🖨 Print Report
          </button>
        </div>
      </div>
    </div>
    </Transition>
    <AppModal
      v-if="showDeleteModal"
      type="delete"
      title="Delete Leave Record"
      message="Are you sure you want to delete this leave record?"
      :detail="deleteTarget?.employeeName + ' — ' + deleteTarget?.leaveType"
      @confirm="confirmDelete"
      @cancel="showDeleteModal = false"
    />

    <!-- Save Confirmation -->
    <AppModal
      v-if="showSaveModal"
      type="confirm"
      :title="editId ? 'Update Leave Record' : 'Add Leave Record'"
      :message="editId ? 'Save changes to this leave record?' : 'Add this new leave record?'"
      :detail="form.employeeName + ' — ' + form.leaveType"
      :confirmLabel="editId ? 'Yes, Update' : 'Yes, Add'"
      @confirm="confirmSave"
      @cancel="showSaveModal = false"
    />
  </div>
</template>

<style scoped>
.icon-svg { display:inline-flex; align-items:center; justify-content:center; width:18px; height:18px; }
.icon-svg :deep(svg) { width:100%; height:100%; fill:currentColor; }
.page { padding: 24px; }
.toolbar { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:16px; flex-wrap:wrap; }
.toolbar-left, .toolbar-right { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.search-wrap { position:relative; display:inline-flex; align-items:center; }
.search-icon { position:absolute; left:10px; color:#aaa; pointer-events:none; }
.search-input { padding:8px 14px 8px 34px; border:1px solid #ddd; border-radius:8px; font-size:13px; width:240px; outline:none; }
.date-input { padding:8px 12px; border:1px solid #ddd; border-radius:8px; font-size:13px; outline:none; }
.record-count { font-size:13px; color:#888; }
.btn { padding:8px 16px; border-radius:8px; border:none; cursor:pointer; font-size:13px; font-weight:600; display:inline-flex; align-items:center; gap:6px; }
.btn-primary { background:#1a3a5c; color:#fff; }
.btn-secondary { background:#f0f4f8; color:#1a3a5c; border:1px solid #ddd; }
.table-wrapper { overflow-x:auto; overflow-y:auto; max-height:60vh; background:#fff; border-radius:12px; box-shadow:0 2px 12px rgba(0,0,0,0.07); }
.data-table { width:100%; border-collapse:separate; border-spacing:0; font-size:12px; }
.data-table thead tr { background:#1a3a5c; color:#fff; }
.data-table thead tr th { position:sticky; top:0; z-index:2; background:#1a3a5c; }
.data-table th { padding:11px 12px; text-align:left; font-weight:600; white-space:nowrap; }
.data-table td { padding:9px 12px; border-bottom:1px solid #f0f4f8; vertical-align:middle; }
.data-table tbody tr:hover { background:#dbeafe !important; box-shadow: inset 3px 0 0 #1a6b3c; }
.sub-text { font-size:11px; color:#888; }

/* ── Employee name — doc-type clickable style (matches TrackingReceiving) ── */
.doc-type { font-size:12px; color:#2980b9; font-weight:600; cursor:pointer; text-decoration:underline; }
.doc-type:hover { color:#1a5276; }
.doc-type.clickable { color:#e74c3c; font-weight:700; background:#fdecea; padding:2px 8px; border-radius:4px; text-decoration:none; display:inline-block; transition: background 0.15s, color 0.15s, box-shadow 0.15s, transform 0.15s; }
.doc-type.clickable:hover { background:#fadbd8; color:#c0392b; box-shadow:0 2px 6px rgba(231,76,60,0.3); animation: badgePulse 0.3s ease; }
@keyframes badgePulse {
  0%   { transform: scale(1); }
  50%  { transform: scale(1.1); }
  100% { transform: scale(1.05); }
}

/* ── Blurred overlay for report modal ──────────────────────────────────── */
.modal-overlay-blur {
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
  background: rgba(15, 30, 50, 0.55) !important;
}

/* ── Modal fade-down animation ──────────────────────────────────────────── */
.modal-fade-enter-active { animation: modalFadeDown 0.22s cubic-bezier(0.22,1,0.36,1) both; }
.modal-fade-leave-active { animation: modalFadeDown 0.15s cubic-bezier(0.55,0,1,0.45) reverse both; }
@keyframes modalFadeDown {
  from { opacity: 0; transform: translateY(-18px) scale(0.97); }
  to   { opacity: 1; transform: translateY(0)     scale(1); }
}
/* doc-type clickable hover pulse */
.doc-type.clickable {
  transition: background 0.15s, color 0.15s, box-shadow 0.15s, transform 0.15s;
}
.doc-type.clickable:hover {
  animation: badgePulse 0.3s ease;
}
@keyframes badgePulse {
  0%   { transform: scale(1); }
  50%  { transform: scale(1.1); }
  100% { transform: scale(1.05); }
}
.modal-report {
  width: 700px;
  max-width: 95vw;
  box-shadow: 0 24px 64px rgba(0,0,0,0.35);
}
.report-modal-header {
  background: linear-gradient(135deg, #1a3a5c 0%, #1a6b3c 100%);
  color: #fff;
  border-radius: 12px 12px 0 0;
  padding: 20px 24px;
}
.report-modal-header h3 {
  color: #fff;
  font-size: 17px;
  margin: 0;
  font-weight: 700;
}
.report-modal-header .close-btn {
  color: rgba(255,255,255,0.85);
  padding: 6px;
  border-radius: 6px;
}
.report-modal-header .close-btn:hover {
  background: rgba(255,255,255,0.2);
  color: #fff;
}
.report-header-info {
  display: flex;
  align-items: center;
  gap: 16px;
}
.report-avatar {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: rgba(255,255,255,0.22);
  color: #fff;
  font-size: 22px;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  border: 2px solid rgba(255,255,255,0.45);
  text-shadow: 0 1px 3px rgba(0,0,0,0.3);
}
.report-meta {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-top: 5px;
  flex-wrap: wrap;
}
.report-empno {
  font-size: 12px;
  background: rgba(255,255,255,0.18);
  padding: 2px 10px;
  border-radius: 10px;
  color: #fff;
  font-family: monospace;
  letter-spacing: 0.5px;
}
.report-dept {
  font-size: 12px;
  color: rgba(255,255,255,0.82);
  font-weight: 500;
}
.report-section {
  margin-bottom: 22px;
}
.report-section-title {
  font-size: 12px;
  font-weight: 700;
  color: #1a3a5c;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 8px;
  padding-bottom: 7px;
  border-bottom: 2px solid #e9ecef;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.report-count {
  background: #1a3a5c;
  color: #fff;
  font-size: 10px;
  padding: 1px 7px;
  border-radius: 10px;
  font-weight: 700;
  letter-spacing: 0;
  text-transform: none;
}
.report-empty {
  color: #aaa;
  font-size: 13px;
  text-align: center;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
}
/* ── Leave type summary chips ─────────────────────────────────────────── */
.summary-chips {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}
.summary-chip {
  background: #fff;
  border: 1px solid #e0e8f0;
  border-radius: 10px;
  padding: 12px 16px;
  min-width: 160px;
  flex: 1;
  box-shadow: 0 1px 4px rgba(0,0,0,0.06);
}
.chip-type {
  font-size: 11px;
  font-weight: 700;
  color: #1a3a5c;
  margin-bottom: 6px;
  text-transform: uppercase;
  letter-spacing: 0.4px;
}
.chip-stats {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 6px;
}
.chip-total {
  font-size: 22px;
  font-weight: 800;
  color: #1a3a5c;
  line-height: 1;
}
.chip-unit {
  font-size: 11px;
  color: #888;
  font-weight: 500;
}
.chip-badge {
  font-size: 10px;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 8px;
}
.chip-approved    { background: #eafaf1; color: #1e8449; }
.chip-pending     { background: #fef3e2; color: #d68910; }
.chip-disapproved { background: #fdecea; color: #c0392b; }
/* ── Individual leave record cards ───────────────────────────────────── */
.report-records {
  display: flex;
  flex-direction: column;
  gap: 8px;
  max-height: 320px;
  overflow-y: auto;
  padding-right: 2px;
}
.report-record-card {
  background: #fff;
  border: 1px solid #e0e8f0;
  border-left: 4px solid #1a3a5c;
  border-radius: 8px;
  padding: 12px 16px;
  transition: box-shadow 0.15s, border-left-color 0.15s;
}
.report-record-card:hover {
  box-shadow: 0 3px 12px rgba(0,0,0,0.1);
  border-left-color: #1a6b3c;
}
.rrc-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}
.rrc-type {
  font-size: 13px;
  font-weight: 700;
  color: #1a3a5c;
}
.rrc-dates {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 12px;
  color: #555;
  margin-bottom: 6px;
  flex-wrap: wrap;
}
.rrc-date-label {
  font-size: 10px;
  font-weight: 700;
  color: #aaa;
  text-transform: uppercase;
}
.rrc-date {
  font-family: monospace;
  color: #1a3a5c;
  font-weight: 600;
  background: #f0f4f8;
  padding: 1px 6px;
  border-radius: 4px;
}
.rrc-date-sep { color: #bbb; font-size: 14px; }
.rrc-days {
  margin-left: auto;
  background: #1a3a5c;
  color: #fff;
  font-size: 11px;
  font-weight: 700;
  padding: 2px 9px;
  border-radius: 8px;
}
.rrc-reason {
  font-size: 12px;
  color: #666;
  font-style: italic;
  margin-bottom: 4px;
  padding: 4px 8px;
  background: #f8f9fa;
  border-radius: 4px;
}
.rrc-approved {
  font-size: 11px;
  color: #1e8449;
  font-weight: 600;
  margin-top: 4px;
}
.rrc-approved-label {
  color: #888;
  font-weight: 400;
}
.leave-type { font-size:12px; color:#2980b9; font-weight:600; }
.days-cell { font-weight:700; color:#1a3a5c; text-align:center; }
.reason-cell { max-width:180px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.badge { padding:3px 10px; border-radius:12px; font-size:11px; font-weight:600; }
.badge-orange { background:#fef3e2; color:#e67e22; }
.badge-green  { background:#eafaf1; color:#27ae60; }
.badge-red    { background:#fdecea; color:#c0392b; }
.badge-gray   { background:#f4f4f4; color:#666; }
.action-btns { display:flex; gap:4px; }
.btn-icon { background:none; border:none; cursor:pointer; padding:3px; border-radius:4px; display:inline-flex; align-items:center; }
.btn-icon:hover { background:#f0f4f8; }
.btn-icon.danger:hover { background:#fdecea; }
.empty-row { text-align:center; color:#aaa; padding:40px; }
.modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:1000; }
.modal { background:#fff; border-radius:12px; width:700px; max-width:95vw; max-height:90vh; overflow-y:auto; }
.modal-animated { animation: modalFadeDown 0.22s cubic-bezier(0.22,1,0.36,1) both; }
.modal-header { display:flex; align-items:center; justify-content:space-between; padding:16px 20px; border-bottom:1px solid #f0f4f8; }
.modal-header h3 { margin:0; color:#1a3a5c; }
.form-modal-header { background:linear-gradient(135deg,#1a3a5c 0%,#1a6b3c 100%); border-radius:12px 12px 0 0; border-bottom:none; }
.form-modal-header h3 { color:#fff; font-size:16px; font-weight:700; }
.form-modal-header .close-btn { color:rgba(255,255,255,0.85); border-radius:6px; }
.form-modal-header .close-btn:hover { background:rgba(255,255,255,0.2); color:#fff; }
.close-btn { background:none; border:none; cursor:pointer; color:#888; display:inline-flex; align-items:center; padding:4px; border-radius:4px; }
.close-btn:hover { background:#f0f4f8; }
.modal-body { padding:20px; }
.modal-footer { display:flex; justify-content:flex-end; gap:10px; padding:16px 20px; border-top:1px solid #f0f4f8; }
.form-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(200px, 1fr)); gap:14px; }
.form-group { display:flex; flex-direction:column; gap:4px; }
.form-group.full { grid-column:1 / -1; }
.form-group label { font-size:12px; font-weight:600; color:#555; }
.form-group input, .form-group select, .form-group textarea { padding:8px 12px; border:1px solid #ddd; border-radius:6px; font-size:13px; outline:none; }
.form-group input:disabled { background:#f5f5f5; color:#888; cursor:not-allowed; }
.field-error { font-size:11px; color:#c0392b; margin-top:2px; }
.employee-selector { position:relative; }
.employee-input-wrapper { position:relative; display:flex; align-items:center; }
.employee-search-input { flex:1; padding:8px 36px 8px 12px; border:1px solid #ddd; border-radius:6px; font-size:13px; outline:none; }
.employee-search-input:focus { border-color:#1a6b3c; box-shadow:0 0 0 3px rgba(26,107,60,0.1); }
.clear-employee-btn { position:absolute; right:8px; background:none; border:none; cursor:pointer; color:#888; padding:4px; border-radius:4px; display:flex; align-items:center; }
.clear-employee-btn:hover { background:#f0f4f8; color:#c0392b; }
.employee-dropdown { position:absolute; top:100%; left:0; right:0; background:#fff; border:1px solid #ddd; border-radius:8px; box-shadow:0 8px 24px rgba(0,0,0,0.12); max-height:280px; overflow-y:auto; z-index:1000; margin-top:4px; }
.employee-dropdown-empty { position:absolute; top:100%; left:0; right:0; background:#fff; border:1px solid #ddd; border-radius:8px; padding:16px; text-align:center; color:#888; font-size:12px; z-index:1000; margin-top:4px; }
.employee-option { padding:10px 14px; cursor:pointer; border-bottom:1px solid #f0f4f8; transition:background 0.15s; }
.employee-option:last-child { border-bottom:none; }
.employee-option:hover { background:#f0f9f4; }
.employee-option.selected { background:#e8f5e9; }
.employee-option-main { display:flex; align-items:center; justify-content:space-between; gap:8px; margin-bottom:3px; }
.employee-option-main strong { font-size:13px; color:#1a3a5c; }
.employee-option-no { font-size:11px; color:#888; background:#f0f4f8; padding:2px 8px; border-radius:4px; }
.employee-option-dept { font-size:11px; color:#666; }
.loading-overlay { position:fixed; inset:0; background:rgba(255,255,255,0.9); display:flex; flex-direction:column; align-items:center; justify-content:center; z-index:999; }
.spinner { width:40px; height:40px; border:4px solid #f0f4f8; border-top-color:#1a3a5c; border-radius:50%; animation:spin 0.8s linear infinite; }
@keyframes spin { to { transform:rotate(360deg); } }
.error-banner { background:#fdecea; color:#c0392b; padding:12px 16px; border-radius:8px; margin-bottom:16px; display:flex; align-items:center; justify-content:space-between; }
.btn-retry { background:#c0392b; color:#fff; border:none; padding:6px 12px; border-radius:6px; cursor:pointer; font-size:12px; }
.btn-retry:hover { background:#a93226; }

/* Tabs */
.tabs { display: flex; gap: 4px; margin-bottom: 16px; }
.tab-btn {
  padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer;
  font-size: 13px; font-weight: 600; background: #f0f4f8; color: #555;
  transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px;
}
.tab-btn:hover { background: #e8f0f8; }
.tab-btn.active { background: #1a3a5c; color: #fff; }
.tab-btn .icon-svg :deep(svg) { fill: currentColor; }

/* Report View Styles */
.report-view { padding: 16px 0; }
.report-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(350px, 1fr)); gap: 16px; }
.summary-card { background: #fff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.08); overflow: hidden; border: 1px solid #e9ecef; }
.card-header { display: flex; align-items: center; justify-content: space-between; padding: 14px 16px; background: #f8f9fa; border-bottom: 1px solid #e9ecef; }
.card-title { display: flex; align-items: center; gap: 8px; }
.card-title .icon-svg { color: #1a3a5c; }
.card-title .icon-svg :deep(svg) { fill: #1a3a5c; }
.action-badge { font-size: 12px; font-weight: 600; color: #1a3a5c; }
.card-body { padding: 16px; }
.card-row { display: flex; gap: 8px; margin-bottom: 8px; align-items: flex-start; }
.card-row.full-width { flex-direction: column; gap: 4px; }
.card-label { font-size: 12px; font-weight: 600; color: #666; min-width: 120px; }
.card-value { font-size: 13px; color: #333; flex: 1; word-break: break-word; }
.card-value .sub-text { font-size: 11px; color: #888; margin-top: 2px; }
.card-value.remarks { font-style: italic; color: #666; }
.empty-state { text-align: center; padding: 40px; color: #888; }
</style>