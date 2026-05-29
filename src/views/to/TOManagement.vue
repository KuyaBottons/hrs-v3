<script setup>
import { ref, computed, onMounted } from 'vue'
import { useTravelOrderStore } from '@/stores/travel_orders'
import { useEmployeeStore } from '@/stores/employees'
import { usePermissions } from '@/composables/usePermissions'
import AppModal from '@/components/AppModal.vue'
import { printTravelOrders } from '@/utils/print'

const store = useTravelOrderStore()
const empStore = useEmployeeStore()
const { hasPermission, loadPermissions } = usePermissions()

// Fetch travel orders on component mount
onMounted(async () => {
  await loadPermissions()
  store.fetchRecords()
  empStore.fetchDepartments()
  empStore.fetchEmployees()
})

// Department options for dropdowns
const departmentOptions = computed(() => [
  { label: 'All Departments', value: '' },
  ...empStore.departments.map(d => ({ label: d, value: d }))
])

// Employee search/autocomplete
const empSearch = ref('')
const showEmpDropdown = ref(false)

const filteredEmployees = computed(() => {
  const q = empSearch.value.toLowerCase().trim()
  if (!q) return empStore.employees.slice(0, 20)
  return empStore.employees.filter(e => {
    const full = `${e.lastName} ${e.firstName} ${e.middleName ?? ''}`.toLowerCase()
    const no   = (e.employeeNo ?? '').toLowerCase()
    return full.includes(q) || no.includes(q)
  }).slice(0, 20)
})

function fullName(e) {
  const mid = e.middleName ? ` ${e.middleName.charAt(0)}.` : ''
  return `${e.lastName}, ${e.firstName}${mid}`
}

function selectEmployee(emp) {
  form.value.employeeId  = emp.id
  form.value.employeeNo  = emp.employeeNo
  form.value.employeeName = fullName(emp)
  form.value.department  = emp.department
  empSearch.value        = fullName(emp)
  showEmpDropdown.value  = false
  formErrors.value.employeeName = ''
  formErrors.value.employeeNo   = ''
}

function onEmpSearchBlur() {
  // Delay so click on dropdown item fires first
  setTimeout(() => { showEmpDropdown.value = false }, 180)
}

const svgIcons = {
  search: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>`,
  add: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>`,
  edit: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>`,
  delete: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg>`,
  save: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M17 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V7l-4-4zm-5 16c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3zm3-10H5V5h10v4z"/></svg>`,
  close: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>`,
  eye: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>`,
}
const search = ref('')
const filterStatus = ref('')
const filterDept   = ref('')
const filterDateFrom = ref('')
const filterDateTo   = ref('')
const activeTab = ref('list')
const showForm = ref(false)
const editId = ref(null)
const showViewModal = ref(false)
const viewRecord = ref(null)

// ── Employee Individual Report Modal ─────────────────────────────────────────
const showReportModal  = ref(false)
const reportEmployee   = ref(null)

function openEmployeeReport(r) {
  reportEmployee.value = {
    employeeId:   r.employeeId,
    employeeName: r.employeeName,
    employeeNo:   r.employeeNo,
    department:   r.department,
  }
  showReportModal.value = true
}

function openViewModal(r) {
  viewRecord.value = r
  showViewModal.value = true
}

function generateCertificate(r) {
  const now = new Date().toLocaleString('en-PH', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>Certificate of Appearance</title>
      <style>
        @page {
          size: A4 portrait;
          margin: 20mm;
        }
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        body {
          font-family: 'Times New Roman', serif;
          font-size: 12pt;
          color: #333;
          line-height: 1.6;
        }
        .header {
          text-align: center;
          margin-bottom: 30px;
          border-bottom: 3px solid #1a3a5c;
          padding-bottom: 15px;
        }
        .header h1 {
          font-size: 14pt;
          color: #1a3a5c;
          margin-bottom: 5px;
          text-transform: uppercase;
          letter-spacing: 1px;
        }
        .header h2 {
          font-size: 12pt;
          color: #1a3a5c;
          margin-bottom: 3px;
        }
        .header h3 {
          font-size: 16pt;
          color: #1a6b3c;
          margin-bottom: 10px;
          font-weight: bold;
          text-transform: uppercase;
        }
        .certificate-title {
          text-align: center;
          font-size: 18pt;
          font-weight: bold;
          color: #1a3a5c;
          margin: 20px 0;
          text-transform: uppercase;
          letter-spacing: 2px;
        }
        .content {
          margin: 30px 0;
          text-align: justify;
        }
        .content p {
          margin-bottom: 15px;
          text-indent: 50px;
        }
        .info-table {
          width: 100%;
          margin: 20px 0;
          border-collapse: collapse;
        }
        .info-table td {
          padding: 8px 0;
          border-bottom: 1px solid #ddd;
        }
        .info-table td:first-child {
          font-weight: bold;
          width: 200px;
          color: #1a3a5c;
        }
        .signature-section {
          margin-top: 50px;
          display: flex;
          justify-content: space-around;
        }
        .signature-block {
          text-align: center;
          width: 250px;
        }
        .signature-line {
          border-top: 2px solid #333;
          margin: 40px auto 5px;
        }
        .signature-label {
          font-size: 11pt;
          color: #666;
          margin-top: 3px;
        }
        .signature-name {
          font-weight: bold;
          color: #1a3a5c;
          font-size: 12pt;
        }
        .footer {
          margin-top: 30px;
          text-align: center;
          font-size: 9pt;
          color: #888;
          border-top: 1px solid #ddd;
          padding-top: 10px;
        }
        @media print {
          body {
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
          }
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Office of the Provincial Health Officer</h1>
        <h2>General Emilio Aguinaldo Memorial Hospital</h2>
        <h2>Korea-Philippines Friendship Hospital</h2>
        <h3>Certificate of Appearance</h3>
      </div>

      <div class="certificate-title">
        CERTIFICATE OF APPEARANCE
      </div>

      <div class="content">
        <p>This is to certify that <strong>${r.employeeName}</strong>, with Employee No. <strong>${r.employeeNo}</strong>, from the <strong>${r.department}</strong> department, has officially appeared and reported for duty/travel to <strong>${r.destination}</strong> from <strong>${r.dateFrom}</strong> to <strong>${r.dateTo}</strong>, covering a period of <strong>${r.days} day(s)</strong>.</p>
        
        <p>The purpose of this travel is: <strong>${r.purpose}</strong></p>
        
        <p>This certification is issued upon the employee's compliance with the travel order requirements and proper documentation of their appearance during the specified period.</p>
      </div>

      <table class="info-table">
        <tr>
          <td>Employee Name:</td>
          <td>${r.employeeName}</td>
        </tr>
        <tr>
          <td>Employee No:</td>
          <td>${r.employeeNo}</td>
        </tr>
        <tr>
          <td>Department:</td>
          <td>${r.department}</td>
        </tr>
        <tr>
          <td>Destination:</td>
          <td>${r.destination}</td>
        </tr>
        <tr>
          <td>Period of Travel:</td>
          <td>${r.dateFrom} to ${r.dateTo} (${r.days} day(s))</td>
        </tr>
        <tr>
          <td>Transport:</td>
          <td>${r.transport}</td>
        </tr>
        <tr>
          <td>Travel Order Status:</td>
          <td>${r.status}</td>
        </tr>
        <tr>
          <td>CA Status:</td>
          <td>${r.caPassed ? 'Passed on ' + r.caDate : 'Pending'}</td>
        </tr>
      </table>

      <div class="signature-section">
        <div class="signature-block">
          <div class="signature-line"></div>
          <div class="signature-name">${r.caReceivedBy || '____________________'}</div>
          <div class="signature-label">Received By</div>
        </div>
        <div class="signature-block">
          <div class="signature-line"></div>
          <div class="signature-label">HR Head / Department Head</div>
        </div>
      </div>

      <div class="footer">
        <p>Generated on ${now} | GEAMH HRIS Travel Order Management System</p>
        <p>This certificate is valid without signature when generated electronically</p>
      </div>
    </body>
    </html>
  `

  const printWindow = window.open('', '_blank', 'width=900,height=700')
  if (printWindow) {
    printWindow.document.write(html)
    printWindow.document.close()
    printWindow.focus()
    setTimeout(() => {
      printWindow.print()
    }, 250)
  } else {
    alert('Please allow popups to print certificate')
  }
}

const employeeTORecords = computed(() => {
  if (!reportEmployee.value) return []
  return store.travelOrders.filter(r => r.employeeId === reportEmployee.value.employeeId)
})

const employeeTOSummary = computed(() => {
  const records = employeeTORecords.value
  return {
    total:       records.length,
    approved:    records.filter(r => r.status === 'Approved').length,
    pending:     records.filter(r => r.status === 'Pending').length,
    disapproved: records.filter(r => r.status === 'Disapproved').length,
    totalDays:   records.reduce((s, r) => s + (Number(r.days) || 0), 0),
    caPassed:    records.filter(r => r.caPassed).length,
  }
})

const blankForm = () => ({
  employeeId: null, employeeNo: '', employeeName: '', department: '', destination: '',
  purpose: '', dateFrom: '', dateTo: '', days: 1,
  transport: 'Public Transport', approvedBy: '', status: 'Pending', remarks: '',
  caPassed: false, caDate: '', caReceivedBy: '', accomplishmentReport: '',
})
const form = ref(blankForm())

const formErrors = ref({ employeeNo: '', employeeName: '' })


function openAdd() {
  editId.value = null
  form.value = blankForm()
  empSearch.value = ''
  formErrors.value = { employeeNo: '', employeeName: '' }
  showForm.value = true
}
function openEdit(r) {
  editId.value = r.id
  form.value = { ...r }
  empSearch.value = r.employeeName
  formErrors.value = { employeeNo: '', employeeName: '' }
  showForm.value = true
}
const showSaveModal = ref(false)
const saving = ref(false)

function save() {
  formErrors.value = { employeeNo: '', employeeName: '' }
  let valid = true
  if (!form.value.employeeNo.trim()) { formErrors.value.employeeNo = 'Employee No. is required.'; valid = false }
  if (!form.value.employeeName.trim()) { formErrors.value.employeeName = 'Employee Name is required.'; valid = false }
  if (!valid) return
  showSaveModal.value = true
}
async function confirmSave() {
  saving.value = true
  try {
    if (editId.value) {
      await store.updateRecord(editId.value, form.value)
    } else {
      await store.addRecord(form.value)
    }
    showSaveModal.value = false
    showForm.value = false
  } catch (err) {
    alert('Error saving travel order: ' + err.message)
  } finally {
    saving.value = false
  }
}
const showDeleteModal = ref(false)
const deleteTarget    = ref(null)

function deleteRec(id) {
  deleteTarget.value = store.travelOrders.find(r => r.id === id)
  showDeleteModal.value = true
}
async function confirmDelete() {
  if (deleteTarget.value) {
    try {
      await store.deleteRecord(deleteTarget.value.id)
      showDeleteModal.value = false
      deleteTarget.value = null
    } catch (err) {
      alert('Error deleting travel order: ' + err.message)
    }
  }
}

const filtered = computed(() => store.travelOrders.filter(r => {
  const q = search.value.toLowerCase()
  const matchSearch = !q || r.employeeName.toLowerCase().includes(q) || r.destination.toLowerCase().includes(q)
  const matchStatus = !filterStatus.value || r.status === filterStatus.value
  const matchDept   = !filterDept.value   || r.department === filterDept.value
  const matchFrom   = !filterDateFrom.value || r.dateFrom >= filterDateFrom.value
  const matchTo     = !filterDateTo.value   || r.dateTo   <= filterDateTo.value
  return matchSearch && matchStatus && matchDept && matchFrom && matchTo
}))

function statusClass(s) {
  return { Pending: 'badge-orange', Approved: 'badge-green', Disapproved: 'badge-red' }[s] || 'badge-gray'
}

const showCAModal = ref(false)
const caRecordId = ref(null)
const caForm = ref({ date: '', receivedBy: '' })

function openCAModal(r) {
  caRecordId.value = r.id
  // CA next day passing logic: suggest the next day after dateTo
  const nextDay = new Date(r.dateTo)
  nextDay.setDate(nextDay.getDate() + 1)
  caForm.value = { date: nextDay.toISOString().split('T')[0], receivedBy: '' }
  showCAModal.value = true
}

async function markCAPassed() {
  if (!caForm.value.date) {
    alert('CA date is required')
    return
  }
  try {
    await store.updateRecord(caRecordId.value, {
      caPassed: true,
      caDate: caForm.value.date,
      caReceivedBy: caForm.value.receivedBy
    })
    showCAModal.value = false
  } catch (err) {
    alert('Error marking CA as passed: ' + err.message)
  }
}
</script>

<template>
  <div class="page">
    <!-- Loading State -->
    <div v-if="store.loading" class="loading-container">
      <div class="spinner"></div>
      <p>Loading travel orders...</p>
    </div>

    <!-- Error State -->
    <div v-if="store.error" class="error-banner">
      <strong>⚠️ Error:</strong> {{ store.error }}
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
          <input v-model="search" class="search-input" placeholder="Search employee, destination..." @keyup.enter="$event.target.blur()" />
        </div>
        <AppSelect
          v-model="filterStatus"
          :options="[{ label: 'All Status', value: '' }, { label: 'Pending', value: 'Pending' }, { label: 'Approved', value: 'Approved' }, { label: 'Disapproved', value: 'Disapproved' }]"
          placeholder="All Status"
        />
        <AppSelect
          v-model="filterDept"
          :options="departmentOptions"
          placeholder="All Departments"
        />
        <input v-model="filterDateFrom" type="date" class="filter-input" title="Date From" />
      </div>
      <div class="toolbar-right">
        <span class="record-count">{{ filtered.length }} record(s)</span>
        <button class="btn btn-print" @click="printTravelOrders(filtered, { Status: filterStatus, Department: filterDept, DateFrom: filterDateFrom, DateTo: filterDateTo })">🖨 Print</button>
        <button v-if="hasPermission('Travel Orders', 'Add')" class="btn btn-primary" @click="openAdd">
          <span class="icon-svg" v-html="svgIcons.add"></span> Add T.O.
        </button>
      </div>
    </div>

    <div class="table-wrapper" v-if="activeTab === 'list'">
      <table class="data-table">
        <thead>
          <tr>
            <th>Employee</th><th>Department</th><th>Destination</th>
            <th>Purpose</th><th>Date From</th><th>Date To</th>
            <th>Days</th><th>Transport</th><th>Status</th><th>CA Status</th><th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="filtered.length === 0"><td colspan="11" class="empty-row">No T.O. records found.</td></tr>
          <tr v-for="r in filtered" :key="r.id">
            <td>
              <span class="doc-type clickable" @click="openEmployeeReport(r)" :title="'View ' + r.employeeName + ' individual report'">{{ r.employeeName }}</span>
              <div class="sub-text">{{ r.employeeNo }}</div>
            </td>
            <td>{{ r.department }}</td>
            <td>{{ r.destination }}</td>
            <td class="purpose-cell">{{ r.purpose }}</td>
            <td>{{ r.dateFrom }}</td>
            <td>{{ r.dateTo }}</td>
            <td class="days-cell">{{ r.days }}</td>
            <td>{{ r.transport }}</td>
            <td><span class="badge" :class="statusClass(r.status)">{{ r.status }}</span></td>
            <td>
              <span v-if="r.caPassed" class="ca-badge ca-passed">Passed ({{ r.caDate }})</span>
              <span v-else class="ca-badge ca-pending">Pending</span>
            </td>
            <td>
              <div class="action-btns">
                <button class="btn-icon" @click="openViewModal(r)" title="View">
                  <span class="icon-svg" v-html="svgIcons.eye"></span>
                </button>
                <button v-if="hasPermission('Travel Orders', 'Edit')" class="btn-icon" @click="openEdit(r)">
                  <span class="icon-svg" v-html="svgIcons.edit"></span>
                </button>
                <button v-if="hasPermission('Travel Orders', 'Delete')" class="btn-icon danger" @click="deleteRec(r.id)">
                  <span class="icon-svg" v-html="svgIcons.delete"></span>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Summary Report View -->
    <div v-if="activeTab === 'summary'" class="report-view">
      <div v-if="store.travelOrders.length === 0" class="empty-state">
        <p>No travel orders found.</p>
      </div>
      <div v-else class="report-grid">
        <div v-for="r in store.travelOrders" :key="r.id" class="summary-card">
          <div class="card-header">
            <div class="card-title">
              <span class="icon-svg" v-html="svgIcons.save"></span>
              <span class="action-badge">Travel Order</span>
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
              <span class="card-label">Destination:</span>
              <span class="card-value">{{ r.destination }}</span>
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
              <span class="card-label">Transport:</span>
              <span class="card-value">{{ r.transport }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">CA Status:</span>
              <span class="badge" :class="r.caPassed ? 'badge-green' : 'badge-orange'">{{ r.caPassed ? 'Passed' : 'Pending' }}</span>
            </div>
            <div class="card-row full-width">
              <span class="card-label">Purpose:</span>
              <span class="card-value remarks">{{ r.purpose || 'NA' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <Transition name="modal-fade">
    <div v-if="showForm" class="modal-overlay modal-overlay-blur" @click.self="showForm = false">
      <div class="modal modal-animated">
        <div class="modal-header form-modal-header">
          <h3>{{ editId ? 'Edit T.O.' : 'Add Travel Order' }}</h3>
          <button class="close-btn" @click="showForm = false">
            <span class="icon-svg" v-html="svgIcons.close"></span>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-grid">
            <div class="form-group full">
              <label>Employee</label>
              <div class="emp-search-wrap">
                <input
                  v-model="empSearch"
                  class="emp-search-input"
                  placeholder="Search by name or employee no..."
                  autocomplete="off"
                  @focus="showEmpDropdown = true"
                  @blur="onEmpSearchBlur"
                  @input="showEmpDropdown = true"
                />
                <div v-if="showEmpDropdown && filteredEmployees.length" class="emp-dropdown">
                  <div
                    v-for="emp in filteredEmployees"
                    :key="emp.id"
                    class="emp-option"
                    @mousedown.prevent="selectEmployee(emp)"
                  >
                    <span class="emp-opt-name">{{ fullName(emp) }}</span>
                    <span class="emp-opt-meta">{{ emp.employeeNo }} · {{ emp.department }}</span>
                  </div>
                </div>
                <div v-if="showEmpDropdown && empSearch && !filteredEmployees.length" class="emp-dropdown">
                  <div class="emp-option emp-no-result">No employees found.</div>
                </div>
              </div>
              <div v-if="form.employeeName" class="emp-selected-info">
                <span class="emp-tag">✓ {{ form.employeeName }}</span>
                <span class="emp-tag-sub">{{ form.employeeNo }} · {{ form.department }}</span>
              </div>
              <span v-if="formErrors.employeeName" class="field-error">{{ formErrors.employeeName }}</span>
            </div>
            <div class="form-group"><label>Department</label>
              <AppSelect
                v-model="form.department"
                :options="empStore.departments"
                placeholder="Select department..."
              />
            </div>
            <div class="form-group full"><label>Destination</label><input v-model="form.destination" /></div>
            <div class="form-group full"><label>Purpose</label><textarea v-model="form.purpose" rows="2"></textarea></div>
            <div class="form-group"><label>Date From</label><input v-model="form.dateFrom" type="date" /></div>
            <div class="form-group"><label>Date To</label><input v-model="form.dateTo" type="date" /></div>
            <div class="form-group"><label>No. of Days</label><input v-model.number="form.days" type="number" min="1" /></div>
            <div class="form-group"><label>Transport</label>
              <AppSelect v-model="form.transport" :options="['Public Transport', 'Government Vehicle', 'Private Vehicle']" />
            </div>
            <div class="form-group"><label>Approved By</label><input v-model="form.approvedBy" /></div>
            <div class="form-group"><label>Status</label>
              <AppSelect v-model="form.status" :options="['Pending', 'Approved', 'Disapproved']" />
            </div>
            <div class="form-group full"><label>Remarks</label><textarea v-model="form.remarks" rows="2"></textarea></div>
            <div class="form-group full"><label>Accomplishment Report</label><textarea v-model="form.accomplishmentReport" rows="3" placeholder="Enter accomplishment report details..."></textarea></div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showForm = false" :disabled="saving">Cancel</button>
          <button class="btn btn-primary" @click="save" :disabled="saving">
            <span v-if="saving" class="spinner-small"></span>
            <span v-else class="icon-svg" v-html="svgIcons.save"></span>
            {{ saving ? 'Saving...' : 'Save' }}
          </button>
        </div>
      </div>
    </div>
    </Transition>

    <!-- Employee Individual Report Modal -->
    <Transition name="modal-fade">
    <div v-if="showReportModal" class="modal-overlay modal-overlay-blur" @click.self="showReportModal = false">
      <div class="modal modal-report modal-animated">
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
          <!-- Summary Stats -->
          <div class="report-section">
            <h4 class="report-section-title">Travel Order Summary</h4>
            <div v-if="employeeTORecords.length === 0" class="report-empty">No travel orders found.</div>
            <div v-else class="summary-chips">
              <div class="summary-chip">
                <div class="chip-type">Total Orders</div>
                <div class="chip-stats">
                  <span class="chip-total">{{ employeeTOSummary.total }}</span>
                  <span class="chip-unit">order{{ employeeTOSummary.total !== 1 ? 's' : '' }}</span>
                </div>
              </div>
              <div class="summary-chip">
                <div class="chip-type">Total Days</div>
                <div class="chip-stats">
                  <span class="chip-total">{{ employeeTOSummary.totalDays }}</span>
                  <span class="chip-unit">day{{ employeeTOSummary.totalDays !== 1 ? 's' : '' }}</span>
                </div>
              </div>
              <div class="summary-chip">
                <div class="chip-type">By Status</div>
                <div class="chip-stats">
                  <span v-if="employeeTOSummary.approved"    class="chip-badge chip-approved">{{ employeeTOSummary.approved }} approved</span>
                  <span v-if="employeeTOSummary.pending"     class="chip-badge chip-pending">{{ employeeTOSummary.pending }} pending</span>
                  <span v-if="employeeTOSummary.disapproved" class="chip-badge chip-disapproved">{{ employeeTOSummary.disapproved }} disapproved</span>
                </div>
              </div>
              <div class="summary-chip">
                <div class="chip-type">CA Status</div>
                <div class="chip-stats">
                  <span class="chip-badge chip-approved">{{ employeeTOSummary.caPassed }} passed</span>
                  <span class="chip-badge chip-pending">{{ employeeTOSummary.total - employeeTOSummary.caPassed }} pending</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Detailed Records -->
          <div class="report-section">
            <h4 class="report-section-title">Travel Orders <span class="report-count">{{ employeeTORecords.length }}</span></h4>
            <div v-if="employeeTORecords.length === 0" class="report-empty">No travel orders found.</div>
            <div v-else class="report-records">
              <div v-for="rec in employeeTORecords" :key="rec.id" class="report-record-card">
                <div class="rrc-top">
                  <span class="rrc-destination">{{ rec.destination }}</span>
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
                <div class="rrc-row">
                  <span class="rrc-label">Transport:</span>
                  <span class="rrc-val">{{ rec.transport }}</span>
                  <span class="ca-badge" :class="rec.caPassed ? 'ca-passed' : 'ca-pending'" style="margin-left:auto">
                    CA: {{ rec.caPassed ? 'Passed' : 'Pending' }}
                  </span>
                </div>
                <div v-if="rec.purpose" class="rrc-reason">{{ rec.purpose }}</div>
                <div v-if="rec.approvedBy" class="rrc-approved">
                  <span class="rrc-approved-label">Approved by:</span> {{ rec.approvedBy }}
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showReportModal = false">Close</button>
          <button class="btn btn-primary" @click="printTravelOrders(employeeTORecords, { Employee: reportEmployee?.employeeName })">
            🖨 Print Report
          </button>
        </div>
      </div>
    </div>
    </Transition>

    <!-- Delete Confirmation -->
    <AppModal
      v-if="showDeleteModal"
      type="delete"
      title="Delete Travel Order"
      message="Are you sure you want to delete this travel order?"
      :detail="deleteTarget?.employeeName + ' — ' + deleteTarget?.destination"
      @confirm="confirmDelete"
      @cancel="showDeleteModal = false"
    />

    <!-- Save Confirmation -->
    <AppModal
      v-if="showSaveModal"
      type="confirm"
      :title="editId ? 'Update Travel Order' : 'Add Travel Order'"
      :message="editId ? 'Save changes to this travel order?' : 'Add this new travel order?'"
      :detail="form.employeeName + ' — ' + form.destination"
      :confirmLabel="editId ? 'Yes, Update' : 'Yes, Add'"
      @confirm="confirmSave"
      @cancel="showSaveModal = false"
    />

    <!-- CA Passing Modal -->
    <Transition name="modal-fade">
    <div v-if="showCAModal" class="modal-overlay modal-overlay-blur" @click.self="showCAModal = false">
      <div class="modal modal-animated">
        <div class="modal-header form-modal-header">
          <h3>Pass Certificate of Appearance (CA)</h3>
          <button class="close-btn" @click="showCAModal = false">
            <span class="icon-svg" v-html="svgIcons.close"></span>
          </button>
        </div>
        <div class="modal-body">
          <div class="form-grid">
            <div class="form-group full"><label>CA Date *</label><input v-model="caForm.date" type="date" /></div>
            <div class="form-group full"><label>Received By</label><input v-model="caForm.receivedBy" placeholder="Name of person receiving CA" /></div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showCAModal = false">Cancel</button>
          <button class="btn btn-primary" @click="markCAPassed">Mark as Passed</button>
        </div>
      </div>
    </div>
    </Transition>

    <!-- View Modal -->
    <Transition name="modal-fade">
    <div v-if="showViewModal" class="modal-overlay modal-overlay-blur" @click.self="showViewModal = false">
      <div class="modal modal-animated">
        <div class="modal-header">
          <h3>Travel Order Details</h3>
          <button class="close-btn" @click="showViewModal = false">
            <span class="icon-svg" v-html="svgIcons.close"></span>
          </button>
        </div>
        <div class="modal-body" v-if="viewRecord">
          <div class="view-details">
            <div class="detail-row">
              <span class="detail-label">Employee:</span>
              <span class="detail-value">{{ viewRecord.employeeName }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Employee No:</span>
              <span class="detail-value">{{ viewRecord.employeeNo }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Department:</span>
              <span class="detail-value">{{ viewRecord.department }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Destination:</span>
              <span class="detail-value">{{ viewRecord.destination }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Purpose:</span>
              <span class="detail-value">{{ viewRecord.purpose }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Date From:</span>
              <span class="detail-value">{{ viewRecord.dateFrom }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Date To:</span>
              <span class="detail-value">{{ viewRecord.dateTo }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Days:</span>
              <span class="detail-value">{{ viewRecord.days }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Transport:</span>
              <span class="detail-value">{{ viewRecord.transport }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">Status:</span>
              <span class="badge" :class="statusClass(viewRecord.status)">{{ viewRecord.status }}</span>
            </div>
            <div class="detail-row">
              <span class="detail-label">CA Status:</span>
              <span v-if="viewRecord.caPassed" class="ca-badge ca-passed">Passed ({{ viewRecord.caDate }})</span>
              <span v-else class="ca-badge ca-pending">Pending</span>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="generateCertificate(viewRecord)">🖨 Generate Certificate</button>
          <button class="btn btn-primary" @click="showViewModal = false">Close</button>
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
.toolbar { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 16px; flex-wrap: wrap; }
.toolbar-left, .toolbar-right { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.search-wrap { position: relative; display: inline-flex; align-items: center; }
.search-icon { position: absolute; left: 10px; color: #aaa; pointer-events: none; }
.search-input { padding: 8px 14px 8px 34px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; width: 220px; outline: none; height: 36px; box-sizing: border-box; }
.filter-select { padding: 8px 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; outline: none; background: #fff; height: 36px; box-sizing: border-box; cursor: pointer; transition: border-color 0.2s, box-shadow 0.2s; }
.filter-select:hover { border-color: #1a3a5c; }
.filter-select:focus { border-color: #1a3a5c; box-shadow: 0 0 0 3px rgba(26,58,92,0.15); }
.filter-input { padding: 8px 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; outline: none; background: #fff; height: 36px; box-sizing: border-box; width: 150px; color: #333; }
.filter-input[type="date"] { width: 150px; cursor: pointer; }
.filter-input:focus { border-color: #1a3a5c; }
.search-input:focus { border-color: #1a3a5c; }
.record-count { font-size: 13px; color: #888; }
.btn { padding: 0 16px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; height: 36px; box-sizing: border-box; }
.btn-primary { background: #1a3a5c; color: #fff; }
.btn-print { background: #1a3a5c; color: #fff; }
.btn-print:hover { background: #2980b9; }
.btn-secondary { background: #f0f4f8; color: #1a3a5c; border: 1px solid #ddd; }
.table-wrapper { overflow-x: auto; overflow-y: auto; max-height: 60vh; background: #fff; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.07); }
.data-table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: 12px; }
.data-table thead tr { background: #1a3a5c; color: #fff; }
.data-table thead tr th { position: sticky; top: 0; z-index: 2; background: #1a3a5c; }
.data-table th { padding: 11px 12px; text-align: left; font-weight: 600; white-space: nowrap; }
.data-table td { padding: 9px 12px; border-bottom: 1px solid #f0f4f8; vertical-align: middle; }
.data-table tbody tr:hover { background: #dbeafe !important; box-shadow: inset 3px 0 0 #1a6b3c; }
.sub-text { font-size: 11px; color: #888; }
.purpose-cell { max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.days-cell { font-weight: 700; text-align: center; }
.badge { padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
.badge-orange { background: #fef3e2; color: #e67e22; }
.badge-green { background: #eafaf1; color: #27ae60; }
.badge-red { background: #fdecea; color: #c0392b; }
.ca-badge { padding: 2px 8px; border-radius: 4px; font-size: 10px; font-weight: 600; }
.ca-passed { background: #eafaf1; color: #27ae60; }
.ca-pending { background: #fef3e2; color: #e67e22; }
.action-btns { display: flex; gap: 4px; }
.btn-icon { background: none; border: none; cursor: pointer; padding: 3px; border-radius: 4px; display: inline-flex; align-items: center; }
.btn-icon:hover { background: #f0f4f8; }
.btn-icon.danger:hover { background: #fdecea; }
.empty-row { text-align: center; color: #aaa; padding: 40px; }
.modal-overlay { position: fixed; inset: 0; background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.modal { background: #fff; border-radius: 12px; width: 700px; max-width: 95vw; max-height: 90vh; overflow-y: auto; }
.modal-animated { animation: modalFadeDown 0.22s cubic-bezier(0.22,1,0.36,1) both; }
.modal-header { display: flex; align-items: center; justify-content: space-between; padding: 16px 20px; border-bottom: 1px solid #f0f4f8; }
.modal-header h3 { margin: 0; color: #1a3a5c; }
.form-modal-header { background: linear-gradient(135deg, #1a3a5c 0%, #1a6b3c 100%); border-radius: 12px 12px 0 0; border-bottom: none; }
.form-modal-header h3 { color: #fff; font-size: 16px; font-weight: 700; }
.form-modal-header .close-btn { color: rgba(255,255,255,0.85); border-radius: 6px; }
.form-modal-header .close-btn:hover { background: rgba(255,255,255,0.2); color: #fff; }
.close-btn { background: none; border: none; cursor: pointer; color: #888; display: inline-flex; align-items: center; padding: 4px; border-radius: 4px; }
.close-btn:hover { background: #f0f4f8; }

/* ── Blurred overlay ──────────────────────────────────────────────────────── */
.modal-overlay-blur {
  backdrop-filter: blur(6px);
  -webkit-backdrop-filter: blur(6px);
  background: rgba(15, 30, 50, 0.55) !important;
}

/* ── View Modal Styles ────────────────────────────────────────────────────── */
.view-details {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.detail-row {
  display: flex;
  justify-content: space-between;
  padding: 8px 0;
  border-bottom: 1px solid #f0f4f8;
}
.detail-row:last-child {
  border-bottom: none;
}
.detail-label {
  font-weight: 600;
  color: #666;
  min-width: 120px;
}
.detail-value {
  color: #1a3a5c;
  font-weight: 500;
  text-align: right;
}

/* ── Modal fade-down animation ────────────────────────────────────────────── */
.modal-fade-enter-active { animation: modalFadeDown 0.22s cubic-bezier(0.22,1,0.36,1) both; }
.modal-fade-leave-active { animation: modalFadeDown 0.15s cubic-bezier(0.55,0,1,0.45) reverse both; }
@keyframes modalFadeDown {
  from { opacity: 0; transform: translateY(-18px) scale(0.97); }
  to   { opacity: 1; transform: translateY(0)     scale(1); }
}

/* ── doc-type clickable badge ─────────────────────────────────────────────── */
.doc-type { font-size:12px; color:#2980b9; font-weight:600; cursor:pointer; text-decoration:underline; }
.doc-type:hover { color:#1a5276; }
.doc-type.clickable { color:#e74c3c; font-weight:700; background:#fdecea; padding:2px 8px; border-radius:4px; text-decoration:none; display:inline-block; transition: background 0.15s, color 0.15s, box-shadow 0.15s, transform 0.15s; }
.doc-type.clickable:hover { background:#fadbd8; color:#c0392b; box-shadow:0 2px 6px rgba(231,76,60,0.3); animation: badgePulse 0.3s ease; }
@keyframes badgePulse {
  0%   { transform: scale(1); }
  50%  { transform: scale(1.1); }
  100% { transform: scale(1.05); }
}

/* ── Employee Report Modal ────────────────────────────────────────────────── */
.modal-report { width: 700px; max-width: 95vw; box-shadow: 0 24px 64px rgba(0,0,0,0.35); }
.report-modal-header { background: linear-gradient(135deg, #1a3a5c 0%, #1a6b3c 100%); color: #fff; border-radius: 12px 12px 0 0; padding: 20px 24px; display: flex; align-items: center; justify-content: space-between; }
.report-modal-header h3 { color: #fff; font-size: 17px; margin: 0; font-weight: 700; }
.report-modal-header .close-btn { color: rgba(255,255,255,0.85); padding: 6px; border-radius: 6px; }
.report-modal-header .close-btn:hover { background: rgba(255,255,255,0.2); color: #fff; }
.report-header-info { display: flex; align-items: center; gap: 16px; }
.report-avatar { width: 50px; height: 50px; border-radius: 50%; background: rgba(255,255,255,0.22); color: #fff; font-size: 22px; font-weight: 800; display: flex; align-items: center; justify-content: center; flex-shrink: 0; border: 2px solid rgba(255,255,255,0.45); text-shadow: 0 1px 3px rgba(0,0,0,0.3); }
.report-meta { display: flex; align-items: center; gap: 10px; margin-top: 5px; flex-wrap: wrap; }
.report-empno { font-size: 12px; background: rgba(255,255,255,0.18); padding: 2px 10px; border-radius: 10px; color: #fff; font-family: monospace; letter-spacing: 0.5px; }
.report-dept { font-size: 12px; color: rgba(255,255,255,0.82); font-weight: 500; }
.report-section { margin-bottom: 22px; }
.report-section-title { font-size: 12px; font-weight: 700; color: #1a3a5c; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; padding-bottom: 7px; border-bottom: 2px solid #e9ecef; text-transform: uppercase; letter-spacing: 0.5px; }
.report-count { background: #1a3a5c; color: #fff; font-size: 10px; padding: 1px 7px; border-radius: 10px; font-weight: 700; letter-spacing: 0; text-transform: none; }
.report-empty { color: #aaa; font-size: 13px; text-align: center; padding: 20px; background: #f8f9fa; border-radius: 8px; }
.summary-chips { display: flex; flex-wrap: wrap; gap: 10px; }
.summary-chip { background: #fff; border: 1px solid #e0e8f0; border-radius: 10px; padding: 12px 16px; min-width: 140px; flex: 1; box-shadow: 0 1px 4px rgba(0,0,0,0.06); }
.chip-type { font-size: 11px; font-weight: 700; color: #1a3a5c; margin-bottom: 6px; text-transform: uppercase; letter-spacing: 0.4px; }
.chip-stats { display: flex; flex-wrap: wrap; align-items: baseline; gap: 6px; }
.chip-total { font-size: 22px; font-weight: 800; color: #1a3a5c; line-height: 1; }
.chip-unit { font-size: 11px; color: #888; font-weight: 500; }
.chip-badge { font-size: 10px; font-weight: 700; padding: 2px 8px; border-radius: 8px; }
.chip-approved    { background: #eafaf1; color: #1e8449; }
.chip-pending     { background: #fef3e2; color: #d68910; }
.chip-disapproved { background: #fdecea; color: #c0392b; }
.report-records { display: flex; flex-direction: column; gap: 8px; max-height: 340px; overflow-y: auto; padding-right: 2px; }
.report-record-card { background: #fff; border: 1px solid #e0e8f0; border-left: 4px solid #1a3a5c; border-radius: 8px; padding: 12px 16px; transition: box-shadow 0.15s, border-left-color 0.15s; }
.report-record-card:hover { box-shadow: 0 3px 12px rgba(0,0,0,0.1); border-left-color: #1a6b3c; }
.rrc-top { display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px; }
.rrc-destination { font-size: 13px; font-weight: 700; color: #1a3a5c; }
.rrc-dates { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #555; margin-bottom: 6px; flex-wrap: wrap; }
.rrc-date-label { font-size: 10px; font-weight: 700; color: #aaa; text-transform: uppercase; }
.rrc-date { font-family: monospace; color: #1a3a5c; font-weight: 600; background: #f0f4f8; padding: 1px 6px; border-radius: 4px; }
.rrc-date-sep { color: #bbb; font-size: 14px; }
.rrc-days { margin-left: auto; background: #1a3a5c; color: #fff; font-size: 11px; font-weight: 700; padding: 2px 9px; border-radius: 8px; }
.rrc-row { display: flex; align-items: center; gap: 8px; font-size: 12px; color: #555; margin-bottom: 5px; }
.rrc-label { font-size: 10px; font-weight: 700; color: #aaa; text-transform: uppercase; }
.rrc-val { font-size: 12px; color: #333; }
.rrc-reason { font-size: 12px; color: #666; font-style: italic; margin-bottom: 4px; padding: 4px 8px; background: #f8f9fa; border-radius: 4px; }
.rrc-approved { font-size: 11px; color: #1e8449; font-weight: 600; margin-top: 4px; }
.rrc-approved-label { color: #888; font-weight: 400; }
.modal-body { padding: 20px; }
.modal-footer { display: flex; justify-content: flex-end; gap: 10px; padding: 16px 20px; border-top: 1px solid #f0f4f8; }
.form-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 14px; }
.form-group { display: flex; flex-direction: column; gap: 4px; }
.form-group.full { grid-column: 1 / -1; }
.form-group label { font-size: 12px; font-weight: 600; color: #555; }
.form-group input, .form-group select, .form-group textarea { padding: 8px 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 13px; outline: none; }
.field-error { font-size: 11px; color: #c0392b; margin-top: 2px; }
.loading-container {
  display: flex; flex-direction: column; align-items: center;
  justify-content: center; padding: 60px; gap: 16px;
}
.spinner {
  width: 40px; height: 40px; border: 4px solid #f0f4f8;
  border-top-color: #1a3a5c; border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }
.spinner-small {
  display: inline-block; width: 14px; height: 14px;
  border: 2px solid rgba(255,255,255,0.3);
  border-top-color: #fff; border-radius: 50%;
  animation: spin 0.6s linear infinite;
}
.error-banner {
  background: #fdecea; border: 1px solid #f5b7b1;
  color: #c0392b; padding: 14px 18px; border-radius: 8px;
  margin-bottom: 16px; display: flex; align-items: center;
  justify-content: space-between; gap: 12px;
}
.btn-retry {
  padding: 6px 14px; background: #c0392b; color: #fff;
  border: none; border-radius: 6px; cursor: pointer;
  font-size: 12px; font-weight: 600;
}
.btn-retry:hover { background: #a93226; }
.btn-primary:disabled, .btn-secondary:disabled {
  opacity: 0.5; cursor: not-allowed;
}

/* Employee search autocomplete */
.emp-search-wrap { position: relative; }
.emp-search-input {
  width: 100%; padding: 8px 12px; border: 1px solid #ddd;
  border-radius: 6px; font-size: 13px; outline: none;
  box-sizing: border-box;
}
.emp-search-input:focus { border-color: #1a3a5c; }
.emp-dropdown {
  position: absolute; top: calc(100% + 4px); left: 0; right: 0;
  background: #fff; border: 1px solid #ddd; border-radius: 8px;
  box-shadow: 0 8px 24px rgba(0,0,0,0.12); z-index: 9999;
  max-height: 220px; overflow-y: auto;
}
.emp-option {
  padding: 9px 14px; cursor: pointer; display: flex;
  flex-direction: column; gap: 2px; transition: background 0.15s;
}
.emp-option:hover { background: #f0f9f4; }
.emp-opt-name { font-size: 13px; font-weight: 600; color: #1a3a5c; }
.emp-opt-meta { font-size: 11px; color: #888; }
.emp-no-result { color: #aaa; font-size: 13px; cursor: default; }
.emp-selected-info {
  display: flex; align-items: center; gap: 10px;
  margin-top: 6px; flex-wrap: wrap;
}
.emp-tag {
  font-size: 12px; font-weight: 600; color: #1a6b3c;
  background: #eafaf1; padding: 3px 10px; border-radius: 12px;
}
.emp-tag-sub { font-size: 11px; color: #888; }

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

