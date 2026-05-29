<script setup>
import { ref, computed, onMounted } from 'vue'
import { useTrackingStore } from '@/stores/tracking'
import { usePermissions } from '@/composables/usePermissions'
import { printTrackingRecords } from '@/utils/print'

const store = useTrackingStore()
const { hasPermission, loadPermissions } = usePermissions()

// Fetch tracking records on component mount
onMounted(async () => {
  await loadPermissions()
  store.fetchRecords()
})

const svgIcons = {
  search:   `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M15.5 14h-.79l-.28-.27A6.47 6.47 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>`,
  add:      `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>`,
  edit:     `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>`,
  receive:  `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M20 8h-3V4H3c-1.1 0-2 .9-2 2v11h2c0 1.66 1.34 3 3 3s3-1.34 3-3h6c0 1.66 1.34 3 3 3s3-1.34 3-3h2v-5l-3-4z"/></svg>`,
  send:     `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/></svg>`,
  save:     `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M17 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V7l-4-4zm-5 16c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3zm3-10H5V5h10v4z"/></svg>`,
  close:    `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>`,
  print:    `<svg viewBox="0 0 24 24" fill="currentColor"><path d="M19 8H5c-1.66 0-3 1.34-3 3v6h4v4h12v-4h4v-6c0-1.66-1.34-3-3-3zm-3 11H8v-5h8v5zm3-7c-.55 0-1-.45-1-1s.45-1 1-1 1 .45 1 1-.45 1-1 1zm-1-9H6v4h12V3z"/></svg>`,
}

// ── Tab: Receiving / Outgoing ─────────────────────────────────────────────────
const activeTab = ref('receiving')

const AMELA = 'Gonzales, Realyn P. (HR AMELA)'

const search       = ref('')
const filterType   = ref('')
const filterStatus = ref('')
const sortBy       = ref('dateForwarded')
const sortOrder    = ref('desc')
const dateFilter   = ref('all') // all, yesterday, present
const printMode    = ref('current') // current, combined
const showForm     = ref(false)
const editId       = ref(null)
const isOutgoing   = ref(false)

const dateFilterOptions = [
  { value: 'all', label: 'All Dates' },
  { value: 'yesterday', label: 'Yesterday' },
  { value: 'present', label: 'Present (Today)' },
]

const printModeOptions = [
  { value: 'current', label: 'Current Tab Only' },
  { value: 'combined', label: 'Combined IN/OUT' },
]

const sortOptions = [
  { value: 'dateForwarded', label: 'Date Forwarded' },
  { value: 'dateReceived', label: 'Date Received' },
  { value: 'docNo', label: 'Document No.' },
  { value: 'from', label: 'From' },
  { value: 'route', label: 'Route' },
  { value: 'status', label: 'Status' },
]

const docTypes = ['DTR Transmittal', 'Leave Form', 'Travel Order', 'Memorandum', 'Other']
const receivingStatuses = ['Pending', 'In Transit', 'Received', 'Returned', 'Lost']
const outgoingStatuses  = ['Sent']
const classificationOptions = ['Specific', 'Optional']

const blankReceiving = () => ({
  direction: 'incoming',
  docType: 'DTR Transmittal', docNo: '', from: '', route: '',
  dateForwarded: new Date().toISOString().split('T')[0], dateReceived: '',
  receivedBy: AMELA, status: 'Pending', remarks: '', linkedOutgoingId: null,
})
const blankOutgoing = () => ({
  direction: 'outgoing',
  docType: 'DTR Transmittal', docNo: '', from: 'HR Office', to: '', route: '',
  dateForwarded: new Date().toISOString().split('T')[0],
  receivedBy: AMELA, status: 'Sent', remarks: '', linkedOutgoingId: null, classification: 'Specific',
})

const form = ref(blankReceiving())
const saving = ref(false)

// Separate receiving and outgoing records from store
const receivingRecords = computed(() =>
  store.trackingRecords.filter(r => r.direction === 'incoming')
)
const outgoingRecords = computed(() =>
  store.trackingRecords.filter(r => r.direction === 'outgoing')
)

const currentRecords = computed(() =>
  activeTab.value === 'receiving' ? receivingRecords.value : outgoingRecords.value
)

const filtered = computed(() => {
  let list = currentRecords.value.filter(r => {
    const q = search.value.toLowerCase()
    const ms = !q || (r.docNo||'').toLowerCase().includes(q) || (r.from||'').toLowerCase().includes(q) || (r.route||'').toLowerCase().includes(q)
    const mt = !filterType.value   || r.docType === filterType.value
    const mst= !filterStatus.value || r.status  === filterStatus.value
    return ms && mt && mst
  })
  
  // Apply date filter for outgoing records
  if (activeTab.value === 'outgoing' && dateFilter.value !== 'all') {
    const today = new Date()
    const yesterday = new Date(today)
    yesterday.setDate(yesterday.getDate() - 1)
    
    const todayStr = today.toISOString().split('T')[0]
    const yesterdayStr = yesterday.toISOString().split('T')[0]
    
    list = list.filter(r => {
      const date = r.dateForwarded
      if (dateFilter.value === 'present') return date === todayStr
      if (dateFilter.value === 'yesterday') return date === yesterdayStr
      return true
    })
  }
  
  // Sort by selected field
  list.sort((a, b) => {
    const aVal = a[sortBy.value] || ''
    const bVal = b[sortBy.value] || ''
    const comparison = aVal.localeCompare(bVal, undefined, { numeric: true, sensitivity: 'base' })
    return sortOrder.value === 'asc' ? comparison : -comparison
  })
  
  return list
})

function openAdd() {
  editId.value   = null
  isOutgoing.value = activeTab.value === 'outgoing'
  form.value     = isOutgoing.value ? blankOutgoing() : blankReceiving()
  showForm.value = true
}

function createOutgoingFrom(r) {
  editId.value   = null
  isOutgoing.value = true
  form.value = {
    ...blankOutgoing(),
    docType: r.docType,
    docNo: r.docNo,
    from: r.from,
    remarks: `Linked from receiving record ${r.docNo}`,
    linkedOutgoingId: r.id
  }
  showForm.value = true
  activeTab.value = 'outgoing'
}

function openEdit(r) {
  editId.value   = r.id
  isOutgoing.value = r.direction === 'outgoing'
  form.value = { ...r }
  showForm.value = true
}

async function save() {
  saving.value = true
  try {
    let savedRecord
    if (editId.value) {
      savedRecord = await store.updateRecord(editId.value, form.value)
    } else {
      savedRecord = await store.addRecord(form.value)
    }
    
    // If creating an outgoing record from a receiving record, update the receiving record's linked_outgoing_id
    if (form.value.direction === 'outgoing' && form.value.linkedOutgoingId && !editId.value) {
      await store.updateRecord(form.value.linkedOutgoingId, { linked_outgoing_id: savedRecord.id })
    }
    
    showForm.value = false
  } catch (err) {
    alert('Error saving tracking record: ' + err.message)
  } finally {
    saving.value = false
  }
}

function handlePrint() {
  if (printMode.value === 'combined') {
    // Print combined IN/OUT report
    const allRecords = store.trackingRecords
    printTrackingRecords(allRecords, { Type: filterType, Status: filterStatus }, 'Combined IN/OUT')
  } else {
    // Print current tab only
    printTrackingRecords(filtered.value, { Type: filterType, Status: filterStatus }, activeTab.value === 'receiving' ? 'Receiving' : 'Outgoing')
  }
}

async function markReceived(r) {
  try {
    const updatedData = {
      ...r,
      status: 'Received',
      receivedBy: AMELA,
      dateReceived: new Date().toISOString().split('T')[0]
    }
    await store.updateRecord(r.id, updatedData)
  } catch (err) {
    alert('Error marking as received: ' + err.message)
  }
}

const showCancelModal = ref(false)
const cancelRecordId = ref(null)
const cancelForm = ref({ reason: '', pulledBy: '', careOff: '' })

function openCancelModal(r) {
  cancelRecordId.value = r.id
  cancelForm.value = { reason: '', pulledBy: '', careOff: '' }
  showCancelModal.value = true
}

async function markAsCancelled() {
  if (!cancelForm.value.reason) {
    alert('Cancellation reason is required')
    return
  }
  try {
    const res = await fetch(`${store.API}?id=${cancelRecordId.value}&action=cancel`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        cancel_reason: cancelForm.value.reason,
        cancel_pulled_by: cancelForm.value.pulledBy,
        cancel_care_off: cancelForm.value.careOff
      })
    })
    if (!res.ok) throw new Error('Failed to mark as cancelled')
    showCancelModal.value = false
    store.fetchRecords()
  } catch (err) {
    alert('Error marking as cancelled: ' + err.message)
  }
}

function statusClass(s) {
  const map = { Pending:'badge-orange','In Transit':'badge-blue',Received:'badge-green',Returned:'badge-purple',Lost:'badge-red',Sent:'badge-blue',Delivered:'badge-green',Cancelled:'badge-red' }
  return map[s] || 'badge-gray'
}
</script>

<template>
  <div class="page">
    <!-- Loading State -->
    <div v-if="store.loading" class="loading-container">
      <div class="spinner"></div>
      <p>Loading tracking records...</p>
    </div>

    <!-- Error State -->
    <div v-if="store.error" class="error-banner">
      <strong>⚠️ Error:</strong> {{ store.error }}
      <button class="btn-retry" @click="store.fetchRecords()">Retry</button>
    </div>

    <!-- AMELA banner -->
    <div class="amela-banner">
      <span class="icon-svg" v-html="svgIcons.receive"></span>
      Document Tracking — Managed by: <strong>{{ AMELA }}</strong>
    </div>

    <!-- Tabs -->
    <div class="tabs">
      <button class="tab-btn" :class="{ active: activeTab === 'receiving' }" @click="activeTab = 'receiving'">
        <span class="icon-svg" v-html="svgIcons.receive"></span> Receiving
      </button>
      <button class="tab-btn" :class="{ active: activeTab === 'outgoing' }" @click="activeTab = 'outgoing'">
        <span class="icon-svg" v-html="svgIcons.send"></span> Outgoing
      </button>
      <button class="tab-btn" :class="{ active: activeTab === 'report' }" @click="activeTab = 'report'">
        <span class="icon-svg" v-html="svgIcons.print"></span> Report
      </button>
    </div>

    <div class="toolbar">
      <div class="toolbar-left">
        <div class="search-wrap">
          <span class="icon-svg search-icon" v-html="svgIcons.search"></span>
          <input v-model="search" class="search-input" placeholder="Search doc no, from, route..." @keyup.enter="$event.target.blur()" />
        </div>
        <AppSelect v-model="filterType"   :options="[{ label: 'All Doc Types', value: '' }, ...docTypes.map(t => ({ label: t, value: t }))]" placeholder="All Doc Types" />
        <AppSelect v-model="filterStatus" :options="[{ label: 'All Status', value: '' }, ...(activeTab === 'receiving' ? receivingStatuses : outgoingStatuses).map(s => ({ label: s, value: s }))]" placeholder="All Status" />
        <AppSelect v-if="activeTab === 'outgoing'" v-model="dateFilter" :options="dateFilterOptions" placeholder="Date Filter" />
        <AppSelect v-model="sortBy" :options="sortOptions" placeholder="Sort By" />
        <button class="btn btn-secondary" @click="sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'">
          {{ sortOrder.value === 'asc' ? 'A-Z' : 'Z-A' }}
        </button>
      </div>
      <div class="toolbar-right">
        <span class="record-count">{{ filtered.length }} record(s)</span>
        <AppSelect v-model="printMode" :options="printModeOptions" placeholder="Print Mode" />
        <button class="btn btn-print" @click="handlePrint">
          <span class="icon-svg" v-html="svgIcons.print"></span> Print
        </button>
        <button v-if="hasPermission('Tracking / Receiving', 'Add') && (activeTab === 'receiving' || activeTab === 'outgoing')" class="btn btn-primary" @click="openAdd">
          <span class="icon-svg" v-html="svgIcons.add"></span>
          {{ activeTab === 'receiving' ? 'Add Receiving' : 'Add Outgoing' }}
        </button>
      </div>
    </div>

    <!-- Receiving Table -->
    <div v-if="activeTab === 'receiving'" class="table-wrapper">
      <table class="data-table">
        <thead><tr><th>Complete Document</th><th>Doc No.</th><th>From</th><th>Route</th><th>Forwarded</th><th>Received</th><th>Received By</th><th>Status</th><th>Remarks</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-if="filtered.length === 0"><td colspan="10" class="empty-row">No receiving records found.</td></tr>
          <tr v-for="r in filtered" :key="r.id">
            <td><span class="doc-type clickable" @click="activeTab = 'report'">{{ r.docType }}</span></td>
            <td>
              <span class="doc-no">{{ r.docNo }}</span>
              <span v-if="r.linkedOutgoingId" class="linked-badge">Linked</span>
            </td>
            <td>{{ r.from }}</td><td>{{ r.route || '—' }}</td>
            <td>{{ r.dateForwarded }}</td>
            <td>{{ r.dateReceived || 'NA' }}</td>
            <td class="amela-cell">{{ r.receivedBy || 'NA' }}</td>
            <td><span class="badge" :class="statusClass(r.status)">{{ r.status }}</span></td>
            <td class="remarks-cell">{{ r.remarks || 'NA' }}</td>
            <td>
              <div class="action-btns">
                <button v-if="r.status === 'Received' && !r.linkedOutgoingId && !r.cancelled && hasPermission('Tracking / Receiving', 'Add')" class="btn btn-receive-sm" @click="createOutgoingFrom(r)">
                  <span class="icon-svg" v-html="svgIcons.send"></span> Send
                </button>
                <button v-if="r.status !== 'Received' && !r.cancelled && hasPermission('Tracking / Receiving', 'Edit')" class="btn btn-receive-sm" @click="markReceived(r)">
                  <span class="icon-svg" v-html="svgIcons.receive"></span> Receive
                </button>
                <button v-if="!r.cancelled && hasPermission('Tracking / Receiving', 'Edit')" class="btn-icon" @click="openEdit(r)"><span class="icon-svg" v-html="svgIcons.edit"></span></button>
                <button v-if="!r.cancelled && hasPermission('Tracking / Receiving', 'Edit')" class="btn-icon btn-cancel" @click="openCancelModal(r)" title="Mark as Cancelled">
                  <span class="icon-svg" v-html="svgIcons.close"></span>
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Outgoing Table -->
    <div v-if="activeTab === 'outgoing'" class="table-wrapper">
      <table class="data-table">
        <thead><tr><th>Complete Document</th><th>Doc No.</th><th>From</th><th>To</th><th>Route</th><th>Classification</th><th>Date Sent</th><th>Sent By</th><th>Status</th><th>Remarks</th><th>Actions</th></tr></thead>
        <tbody>
          <tr v-if="filtered.length === 0"><td colspan="11" class="empty-row">No outgoing records found.</td></tr>
          <tr v-for="r in filtered" :key="r.id">
            <td><span class="doc-type clickable" @click="activeTab = 'report'">{{ r.docType }}</span></td>
            <td><span class="doc-no">{{ r.docNo }}</span></td>
            <td>{{ r.from }}</td><td>{{ r.to }}</td><td>{{ r.route || '—' }}</td>
            <td><span class="classification-badge" :class="r.classification?.toLowerCase()">{{ r.classification || 'Specific' }}</span></td>
            <td>{{ r.dateForwarded }}</td>
            <td class="amela-cell">{{ r.receivedBy }}</td>
            <td><span class="badge" :class="statusClass(r.status)">{{ r.status }}</span></td>
            <td class="remarks-cell">{{ r.remarks || 'NA' }}</td>
            <td><button v-if="!r.cancelled" class="btn-icon" @click="openEdit(r)"><span class="icon-svg" v-html="svgIcons.edit"></span></button></td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Report View -->
    <div v-if="activeTab === 'report'" class="report-view">
      <div v-if="store.trackingRecords.length === 0" class="empty-state">
        <p>No tracking records found.</p>
      </div>
      <div v-else class="report-grid">
        <div v-for="r in store.trackingRecords" :key="r.id" class="summary-card">
          <div class="card-header">
            <div class="card-title">
              <span class="icon-svg" v-html="svgIcons.print"></span>
              <span class="action-badge">{{ r.docType }}</span>
            </div>
            <span class="badge" :class="statusClass(r.status)">{{ r.status }}</span>
          </div>
          <div class="card-body">
            <div class="card-row">
              <span class="card-label">From:</span>
              <span class="card-value">{{ r.from }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Doc No:</span>
              <span class="card-value emp-no">{{ r.docNo }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Date Forwarded:</span>
              <span class="card-value">{{ r.dateForwarded }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Type:</span>
              <span class="badge badge-blue">{{ r.direction === 'incoming' ? 'Receiving' : 'Outgoing' }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Processed By:</span>
              <span class="card-value">{{ r.receivedBy }}</span>
            </div>
            <div class="card-row">
              <span class="card-label">Timestamp:</span>
              <span class="card-value timestamp">{{ r.dateReceived || r.dateForwarded }}</span>
            </div>
            <div class="card-row full-width">
              <span class="card-label">Remarks:</span>
              <span class="card-value remarks">{{ r.remarks || 'NA' }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Form Modal -->
    <div v-if="showForm" class="modal-overlay" @click.self="showForm = false">
      <div class="modal">
        <div class="modal-header">
          <h3>{{ editId ? 'Edit' : 'Add' }} {{ isOutgoing ? 'Outgoing' : 'Receiving' }} Record</h3>
          <button class="close-btn" @click="showForm = false"><span class="icon-svg" v-html="svgIcons.close"></span></button>
        </div>
        <div class="modal-body">
          <div class="form-grid">
            <div class="form-group"><label>Complete Document</label><AppSelect v-model="form.docType" :options="docTypes" /></div>
            <div class="form-group"><label>Document No.</label><input v-model="form.docNo" placeholder="Auto-generated if empty" /></div>
            <div class="form-group"><label>From</label><input v-model="form.from" /></div>
            <template v-if="!isOutgoing">
              <div class="form-group"><label>Route</label><input v-model="form.route" placeholder="From IMIS receive HR" /></div>
              <div class="form-group"><label>Date Forwarded</label><input v-model="form.dateForwarded" type="date" /></div>
              <div class="form-group"><label>Date Received</label><input v-model="form.dateReceived" type="date" /></div>
              <div class="form-group"><label>Received By</label><input v-model="form.receivedBy" /></div>
              <div class="form-group"><label>Status</label><AppSelect v-model="form.status" :options="receivingStatuses" /></div>
            </template>
            <template v-else>
              <div class="form-group"><label>To</label><input v-model="form.to" /></div>
              <div class="form-group"><label>Route</label><input v-model="form.route" placeholder="From IMIS receive HR" /></div>
              <div class="form-group"><label>Classification</label><AppSelect v-model="form.classification" :options="classificationOptions.map(c => ({ label: c, value: c }))" /></div>
              <div class="form-group"><label>Date Sent</label><input v-model="form.dateForwarded" type="date" /></div>
              <div class="form-group"><label>Sent By</label><input v-model="form.receivedBy" /></div>
              <div class="form-group"><label>Status</label><AppSelect v-model="form.status" :options="outgoingStatuses" /></div>
            </template>
            <div class="form-group full"><label>Remarks</label><textarea v-model="form.remarks" rows="2"></textarea></div>
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

    <!-- Cancel Modal -->
    <div v-if="showCancelModal" class="modal-overlay" @click.self="showCancelModal = false">
      <div class="modal">
        <div class="modal-header">
          <h3>Mark as Cancelled</h3>
          <button class="close-btn" @click="showCancelModal = false"><span class="icon-svg" v-html="svgIcons.close"></span></button>
        </div>
        <div class="modal-body">
          <div class="form-grid">
            <div class="form-group full"><label>Reason for Cancellation *</label><textarea v-model="cancelForm.reason" rows="3" required></textarea></div>
            <div class="form-group"><label>Pulled By (Mr.)</label><input v-model="cancelForm.pulledBy" /></div>
            <div class="form-group"><label>Care Off (Optional)</label><input v-model="cancelForm.careOff" /></div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-secondary" @click="showCancelModal = false">Cancel</button>
          <button class="btn btn-primary btn-danger" @click="markAsCancelled">Mark as Cancelled</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.icon-svg { display:inline-flex; align-items:center; justify-content:center; width:18px; height:18px; }
.icon-svg :deep(svg) { width:100%; height:100%; fill:currentColor; }
.page { padding: 24px; display:flex; flex-direction:column; gap:14px; }
.amela-banner { display:flex; align-items:center; gap:8px; background:#e8f5ee; border:1px solid #c3e6cb; border-radius:8px; padding:8px 16px; font-size:13px; color:#1a6b3c; }
.amela-banner .icon-svg { color:#1a6b3c; }
.amela-banner .icon-svg :deep(svg) { fill:#1a6b3c; }
.tabs { display: flex; gap: 4px; margin-bottom: 16px; }
.tab-btn {
  padding: 8px 16px; border-radius: 8px; border: none; cursor: pointer;
  font-size: 13px; font-weight: 600; background: #f0f4f8; color: #555;
  transition: all 0.2s; display: inline-flex; align-items: center; gap: 6px;
}
.tab-btn:hover { background: #e8f0f8; }
.tab-btn.active { background: #1a3a5c; color: #fff; }
.tab-btn .icon-svg :deep(svg) { fill:currentColor; }
.toolbar { display:flex; align-items:center; justify-content:space-between; gap:12px; flex-wrap:wrap; }
.toolbar-left, .toolbar-right { display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
.search-wrap { position:relative; display:inline-flex; align-items:center; }
.search-icon { position:absolute; left:10px; color:#aaa; pointer-events:none; }
.search-input { padding:8px 14px 8px 34px; border:1px solid #ddd; border-radius:8px; font-size:13px; width:240px; outline:none; }
.record-count { font-size:13px; color:#888; }
.btn { padding:6px 14px; border-radius:6px; border:none; cursor:pointer; font-size:12px; font-weight:600; display:inline-flex; align-items:center; gap:6px; }
.btn-primary { background:#1a3a5c; color:#fff; padding:8px 16px; font-size:13px; }
.btn-primary:hover { background:#2980b9; box-shadow: 0 4px 12px rgba(41,128,185,0.4); transform: translateY(-1px); }
.btn-secondary { background:#f0f4f8; color:#1a3a5c; border:1px solid #ddd; padding:8px 16px; font-size:13px; }
.btn-secondary:hover { background:#e8f0f8; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
.btn-receive-sm { background:#27ae60; color:#fff; font-size:11px; padding:4px 8px; }
.btn-receive-sm:hover { background:#219150; box-shadow: 0 2px 6px rgba(39,174,96,0.4); transform: translateY(-1px); }
.btn-cancel { color:#c0392b; }
.btn-cancel:hover { background:#fdecea; box-shadow: 0 2px 6px rgba(192,57,43,0.2); }
.btn-danger { background:#c0392b; color:#fff; }
.btn-danger:hover { background:#a93226; box-shadow: 0 4px 12px rgba(169,50,38,0.4); transform: translateY(-1px); }
.btn-print { background:#1a3a5c; color:#fff; border:1px solid #1a3a5c; }
.btn-print:hover { background:#2980b9; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
.table-wrapper { overflow-x:auto; overflow-y:auto; max-height:55vh; background:#fff; border-radius:0 12px 12px 12px; box-shadow:0 2px 12px rgba(0,0,0,0.07); }
.data-table { width:100%; border-collapse:separate; border-spacing:0; font-size:12px; }
.data-table thead tr { background:#1a3a5c; color:#fff; }
.data-table thead tr th { position:sticky; top:0; z-index:2; background:#1a3a5c; }
.data-table th { padding:11px 12px; text-align:left; font-weight:600; white-space:nowrap; }
.data-table td { padding:9px 12px; border-bottom:1px solid #f0f4f8; vertical-align:middle; text-align:left; }
.data-table td:first-child, .data-table td:nth-child(2), .data-table td:nth-child(3), .data-table td:nth-child(4) { text-align:left; }
.data-table tbody tr:hover { background:#dbeafe !important; box-shadow: inset 3px 0 0 #1a6b3c, 0 2px 8px rgba(0,0,0,0.08); transform: scale(1.005); }
.doc-type { font-size:12px; color:#2980b9; font-weight:600; cursor:pointer; text-decoration:underline; }
.doc-type:hover { color:#1a5276; text-decoration:underline; box-shadow: 0 1px 4px rgba(41,128,185,0.2); }
.doc-type.clickable { color:#e74c3c; font-weight:700; background:#fdecea; padding:2px 8px; border-radius:4px; text-decoration:none; }
.doc-type.clickable:hover { background:#fadbd8; color:#c0392b; box-shadow: 0 2px 6px rgba(231,76,60,0.3); transform: scale(1.05); }
.doc-no { font-family:monospace; font-size:11px; color:#555; }
.linked-badge { display:inline-block; background:#e8f5e9; color:#2e7d32; font-size:10px; padding:1px 6px; border-radius:10px; margin-left:6px; font-weight:600; }
.classification-badge { display:inline-block; padding:2px 8px; border-radius:4px; font-size:10px; font-weight:600; }
.classification-badge.specific { background:#e3f2fd; color:#1976d2; }
.classification-badge.optional { background:#fff3e0; color:#f57c00; }
.amela-cell { font-size:11px; color:#1a6b3c; font-weight:600; }
.remarks-cell { max-width:150px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.badge { padding:3px 10px; border-radius:12px; font-size:11px; font-weight:600; }
.badge-orange { background:#fef3e2; color:#e67e22; }
.badge-blue   { background:#ebf5fb; color:#2980b9; }
.badge-green  { background:#eafaf1; color:#27ae60; }
.badge-purple { background:#f5eef8; color:#8e44ad; }
.badge-red    { background:#fdecea; color:#c0392b; }
.badge-gray   { background:#f4f4f4; color:#666; }
.action-btns { display:flex; gap:6px; align-items:center; }
.btn-icon { background:none; border:none; cursor:pointer; padding:6px; border-radius:6px; display:inline-flex; align-items:center; transition:all 0.2s; }
.btn-icon:hover { background:#e8f0f8; box-shadow: 0 2px 6px rgba(0,0,0,0.1); transform: scale(1.1); }
.empty-row { text-align:center; color:#aaa; padding:40px; }
.modal-overlay { position:fixed; inset:0; background:rgba(0,0,0,0.5); display:flex; align-items:center; justify-content:center; z-index:1000; }
.modal { background:#fff; border-radius:12px; width:700px; max-width:95vw; max-height:90vh; overflow-y:auto; }
.modal-header { display:flex; align-items:center; justify-content:space-between; padding:16px 20px; border-bottom:1px solid #f0f4f8; }
.modal-header h3 { margin:0; color:#1a3a5c; }
.close-btn { background:none; border:none; cursor:pointer; color:#888; display:inline-flex; align-items:center; padding:6px; border-radius:6px; transition:all 0.2s; }
.close-btn:hover { background:#f0f4f8; color:#555; box-shadow: 0 2px 6px rgba(0,0,0,0.1); transform: scale(1.1); }
.modal-body { padding:20px; }
.modal-footer { display:flex; justify-content:flex-end; gap:10px; padding:16px 20px; border-top:1px solid #f0f4f8; }
.form-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(200px, 1fr)); gap:14px; }
.form-group { display:flex; flex-direction:column; gap:4px; }
.form-group.full { grid-column:1/-1; }
.form-group label { font-size:12px; font-weight:600; color:#555; }
.form-group input, .form-group select, .form-group textarea { padding:8px 12px; border:1px solid #ddd; border-radius:6px; font-size:13px; outline:none; }
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
.card-value.emp-no { font-family: monospace; font-size: 12px; color: #555; }
.card-value.timestamp { font-size: 12px; color: #888; }
.card-value.remarks { font-style: italic; color: #666; }
.empty-state { text-align: center; padding: 40px; color: #888; }
</style>
