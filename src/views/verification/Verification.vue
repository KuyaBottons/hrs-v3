<script setup>
import { ref, computed } from 'vue'
import { useDTRStore } from '@/stores/dtr'
import { usePermissions } from '@/composables/usePermissions'
import { onMounted } from 'vue'

const dtrStore = useDTRStore()
const { hasPermission, loadPermissions } = usePermissions()

onMounted(async () => {
  await loadPermissions()
})

const svgIcons = {
  search: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>`,
  verify: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/></svg>`,
  check: `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>`,
}

const search = ref('')
const filterStatus = ref('')
const activeTab = ref('list')

const items = computed(() => dtrStore.dtrRecords.filter(r => {
  const q = search.value.toLowerCase()
  const matchSearch = !q || r.employeeName.toLowerCase().includes(q)
  const matchStatus = !filterStatus.value || r.status === filterStatus.value
  return matchSearch && matchStatus
}))

function verify(rec) {
  const verifier = prompt('Enter verifier name:')
  if (verifier) {
    dtrStore.updateRecord(rec.id, {
      verifiedBy: verifier,
      verificationDate: new Date().toISOString().split('T')[0],
      status: 'Verified',
    })
  }
}

function statusClass(s) {
  const map = { Pending: 'badge-orange', Submitted: 'badge-blue', Received: 'badge-green', Verified: 'badge-purple', Returned: 'badge-red' }
  return map[s] || 'badge-gray'
}

function printVerification() {
  const now = new Date().toLocaleString('en-PH', {
    year: 'numeric', month: 'long', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })

  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <title>DTR Verification Report</title>
      <style>
        @page { size: A4 landscape; margin: 15mm; }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; font-size: 10pt; color: #333; padding: 20px; }
        .header { text-align: center; margin-bottom: 20px; border-bottom: 3px solid #1a6b3c; padding-bottom: 15px; }
        .header h1 { font-size: 18pt; color: #1a6b3c; margin-bottom: 5px; }
        .filter-summary { background: #e8f5ee; padding: 8px 12px; margin-bottom: 10px; border-left: 3px solid #1a6b3c; font-size: 9pt; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background: #1a6b3c; color: white; padding: 8px 6px; text-align: left; font-weight: 600; font-size: 9pt; border: 1px solid #0d2a3c; }
        td { padding: 6px; border: 1px solid #ddd; font-size: 9pt; }
        tr:nth-child(even) { background: #e8f5ee; }
        .footer { margin-top: 20px; padding-top: 10px; border-top: 1px solid #ddd; text-align: center; font-size: 8pt; color: #888; }
        .record-count { margin-top: 10px; font-weight: 600; color: #1a6b3c; }
        @media print { body { -webkit-print-color-adjust: exact; print-color-adjust: exact; } }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>DTR Verification Report</h1>
        <div class="subtitle">General Emilio Aguinaldo Memorial Hospital</div>
        <div class="timestamp">Generated: ${now}</div>
      </div>
      <div class="filter-summary">
        Status: ${filterStatus.value || 'All'} | Records: ${items.length}
      </div>
      <div class="record-count">Total Records: ${items.length}</div>
      <table>
        <thead>
          <tr>
            <th>Employee</th>
            <th>Department</th>
            <th>Period</th>
            <th>Type</th>
            <th>Submitted By</th>
            <th>Date Submitted</th>
            <th>Status</th>
            <th>Verified By</th>
            <th>Verification Date</th>
          </tr>
        </thead>
        <tbody>
          ${items.map(r => `
            <tr>
              <td><strong>${r.employeeName}</strong><br><small>${r.employeeNo}</small></td>
              <td>${r.department}</td>
              <td>${r.period}</td>
              <td>${r.transmittalType}</td>
              <td>${r.submittedBy}</td>
              <td>${r.dateSubmitted}</td>
              <td>${r.status}</td>
              <td>${r.verifiedBy || '—'}</td>
              <td>${r.verificationDate || '—'}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
      <div class="footer">Generated on ${now} | GEAMH HRIS System</div>
    </body>
    </html>
  `

  const printWindow = window.open('', '_blank')
  printWindow.document.write(html)
  printWindow.document.close()
  printWindow.focus()
  setTimeout(() => printWindow.print(), 250)
}

function downloadCSV() {
  const headers = ['Employee Name', 'Employee No', 'Department', 'Period', 'Type', 'Submitted By', 'Date Submitted', 'Status', 'Verified By', 'Verification Date']
  const rows = items.map(r => [
    r.employeeName,
    r.employeeNo,
    r.department,
    r.period,
    r.transmittalType,
    r.submittedBy,
    r.dateSubmitted,
    r.status,
    r.verifiedBy || '',
    r.verificationDate || ''
  ])

  const csvContent = [
    headers.join(','),
    ...rows.map(row => row.map(cell => `"${cell}"`).join(','))
  ].join('\n')

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  const url = URL.createObjectURL(blob)
  link.setAttribute('href', url)
  link.setAttribute('download', `dtr_verification_${new Date().toISOString().split('T')[0]}.csv`)
  link.style.visibility = 'hidden'
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}
</script>

<template>
  <div class="page">
    <div class="info-banner">
      <span class="icon-svg banner-icon" v-html="svgIcons.verify"></span>
      <div>
        <strong>Verification Module</strong>
        <p>Review and verify DTR transmittals, leave forms, and other HR documents before processing.</p>
      </div>
    </div>

    <div class="toolbar">
      <div class="toolbar-left">
        <div class="search-wrap">
          <span class="icon-svg search-icon" v-html="svgIcons.search"></span>
          <input v-model="search" class="search-input" placeholder="Search employee..." @keyup.enter="$event.target.blur()" />
        </div>
        <AppSelect
          v-model="filterStatus"
          :options="[{ label: 'All Status', value: '' }, ...dtrStore.statuses.map(s => ({ label: s, value: s }))]"
          placeholder="All Status"
        />
        <div class="tabs">
          <button class="tab-btn" :class="{ active: activeTab === 'list' }" @click="activeTab = 'list'">List</button>
          <button class="tab-btn" :class="{ active: activeTab === 'report' }" @click="activeTab = 'report'">Report</button>
        </div>
      </div>
      <div class="toolbar-right">
        <span class="record-count">{{ items.length }} item(s)</span>
        <button class="btn btn-download" @click="downloadCSV">⬇ Download</button>
        <button class="btn btn-print" @click="printVerification">🖨 Print</button>
      </div>
    </div>

    <div v-if="activeTab === 'list'">

    <div class="table-wrapper">
      <table class="data-table">
        <thead>
          <tr>
            <th>Employee</th><th>Department</th><th>Period</th>
            <th>Type</th><th>Submitted By</th><th>Date Submitted</th>
            <th>Status</th><th>Verified By</th><th>Verification Date</th><th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-if="items.length === 0"><td colspan="10" class="empty-row">No items for verification.</td></tr>
          <tr v-for="r in items" :key="r.id" :class="{ 'unverified-row': !r.verifiedBy }">
            <td><strong>{{ r.employeeName }}</strong><div class="sub-text">{{ r.employeeNo }}</div></td>
            <td>{{ r.department }}</td>
            <td>{{ r.period }}</td>
            <td><span class="badge" :class="r.transmittalType === 'Main' ? 'badge-blue' : 'badge-purple'">{{ r.transmittalType }}</span></td>
            <td>{{ r.submittedBy }}</td>
            <td>{{ r.dateSubmitted }}</td>
            <td><span class="badge" :class="statusClass(r.status)">{{ r.status }}</span></td>
            <td>{{ r.verifiedBy || '—' }}</td>
            <td>{{ r.verificationDate || '—' }}</td>
            <td>
              <button v-if="hasPermission('Verification', 'Verify') && !r.verifiedBy" class="btn btn-verify" @click="verify(r)">
                <span class="icon-svg" v-html="svgIcons.verify"></span> Verify
              </button>
              <span v-else class="verified-label">
                <span class="icon-svg" v-html="svgIcons.check"></span> Done
              </span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    </div>

    <!-- Report View -->
    <div v-if="activeTab === 'report'">
      <div class="report-grid">
        <div v-for="r in items" :key="r.id" class="report-card" :class="{ 'unverified-card': !r.verifiedBy }">
          <div class="card-header">
            <div class="card-avatar">{{ r.employeeName.split(' ').map(n => n[0]).join('').slice(0,2) }}</div>
            <div class="card-title">{{ r.employeeName }}</div>
            <div class="card-subtitle">{{ r.employeeNo }}</div>
          </div>
          <div class="card-body">
            <div class="card-row">
              <span class="card-label">Department:</span>
              <span class="card-value">{{ r.department }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Period:</span>
              <span class="card-value">{{ r.period }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Type:</span>
              <span class="card-value">{{ r.transmittalType }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Submitted By:</span>
              <span class="card-value">{{ r.submittedBy }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Date Submitted:</span>
              <span class="card-value">{{ r.dateSubmitted }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Status:</span>
              <span class="card-value" :class="statusClass(r.status)">{{ r.status }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Verified By:</span>
              <span class="card-value">{{ r.verifiedBy || '—' }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Verification Date:</span>
              <span class="card-value">{{ r.verificationDate || '—' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.icon-svg { display:inline-flex; align-items:center; justify-content:center; width:18px; height:18px; }
.icon-svg :deep(svg) { width:100%; height:100%; fill:currentColor; }
.page { padding: 24px; }
.info-banner {
  display: flex; align-items: flex-start; gap: 14px;
  background: #ebf5fb; border: 1px solid #a9cce3; border-radius: 10px;
  padding: 16px 20px; margin-bottom: 20px; font-size: 14px;
}
.banner-icon { width: 28px; height: 28px; color: #1a3a5c; flex-shrink: 0; }
.banner-icon :deep(svg) { width: 100%; height: 100%; }
.info-banner strong { color: #1a3a5c; }
.info-banner p { margin: 4px 0 0; color: #555; font-size: 13px; }
.toolbar { display: flex; align-items: center; justify-content: space-between; gap: 12px; margin-bottom: 16px; flex-wrap: wrap; }
.toolbar-left, .toolbar-right { display: flex; align-items: center; gap: 10px; }
.tabs { display: flex; gap: 4px; margin-left: 16px; }
.tab-btn {
  padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer;
  font-size: 13px; font-weight: 600; background: #f0f4f8; color: #555;
  transition: all 0.2s;
}
.tab-btn:hover { background: #e8f0f8; }
.tab-btn.active { background: #1a3a5c; color: #fff; }
.search-wrap { position: relative; display: inline-flex; align-items: center; }
.search-icon { position: absolute; left: 10px; color: #aaa; pointer-events: none; }
.search-input { padding: 8px 14px 8px 34px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; width: 240px; outline: none; }
.filter-select { padding: 8px 12px; border: 1px solid #ddd; border-radius: 8px; font-size: 13px; outline: none; background: #fff; cursor: pointer; transition: border-color 0.2s, box-shadow 0.2s; }
.filter-select:hover { border-color: #1a3a5c; }
.filter-select:focus { border-color: #1a3a5c; box-shadow: 0 0 0 3px rgba(26,58,92,0.15); }
.record-count { font-size: 13px; color: #888; }
.btn { padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer; font-size: 13px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
.btn-print { background: #1a3a5c; color: #fff; }
.btn-print:hover { background: #2980b9; }
.btn-download { background: #27ae60; color: #fff; }
.btn-download:hover { background: #1e8449; }
.table-wrapper { overflow-x: auto; overflow-y: auto; max-height: 60vh; background: #fff; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.07); }
.data-table { width: 100%; border-collapse: separate; border-spacing: 0; font-size: 12px; }
.data-table thead tr { background: #1a3a5c; color: #fff; }
.data-table thead tr th { position: sticky; top: 0; z-index: 2; background: #1a3a5c; }
.data-table th { padding: 11px 12px; text-align: left; font-weight: 600; white-space: nowrap; }
.data-table td { padding: 9px 12px; border-bottom: 1px solid #f0f4f8; vertical-align: middle; }
.data-table tbody tr:hover { background: #dbeafe !important; box-shadow: inset 3px 0 0 #1a6b3c; }
.unverified-row { background: #fffde7 !important; }
.sub-text { font-size: 11px; color: #888; }
.badge { padding: 3px 10px; border-radius: 12px; font-size: 11px; font-weight: 600; }
.badge-orange { background: #fef3e2; color: #e67e22; }
.badge-blue { background: #ebf5fb; color: #2980b9; }
.badge-green { background: #eafaf1; color: #27ae60; }
.badge-purple { background: #f5eef8; color: #8e44ad; }
.badge-red { background: #fdecea; color: #c0392b; }
.badge-gray { background: #f4f4f4; color: #666; }
.btn { padding: 6px 14px; border-radius: 6px; border: none; cursor: pointer; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
.btn-verify { background: #27ae60; color: #fff; }
.btn-verify:hover { background: #1e8449; }
.verified-label { color: #27ae60; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; }
.empty-row { text-align: center; color: #aaa; padding: 40px; }
.report-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 16px;
}
.report-card {
  background: #fff;
  border-radius: 12px;
  padding: 16px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.07);
  border-left: 4px solid #1a3a5c;
}
.report-card.unverified-card {
  background: #fffde7;
  border-left-color: #f39c12;
}
.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 12px;
  padding-bottom: 12px;
  border-bottom: 1px solid #f0f4f8;
}
.card-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  background: linear-gradient(135deg, #1a3a5c, #2980b9);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 16px;
  font-weight: 800;
  color: #fff;
  flex-shrink: 0;
}
.card-title {
  flex: 1;
  font-size: 14px;
  font-weight: 700;
  color: #1a3a5c;
}
.card-subtitle {
  font-size: 12px;
  color: #888;
}
.card-body {
  display: flex;
  flex-direction: column;
  gap: 8px;
}
.card-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.card-label {
  font-size: 12px;
  font-weight: 600;
  color: #555;
}
.card-value {
  font-size: 12px;
  font-weight: 600;
  color: #1a3a5c;
  text-align: right;
}
</style>

