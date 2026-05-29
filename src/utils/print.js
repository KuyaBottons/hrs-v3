/**
 * GEAMH HRIS – Print Utility Functions
 * All formats matched to physical documents used at the hospital.
 *
 * Formats covered:
 *  1. printTable()                  – generic A4 landscape table (base helper)
 *  2. printScheduleOfDuties()       – 31-day grid, grouped by employment type  (Images 1 & 3)
 *  3. printNursingSchedule()        – colored-shift 31-day grid (Image 2)
 *  4. printTransmittalReport()      – department transmittal list (Image 4)
 *  5. printTrainingAttendees()      – training attendees list PDF (Image 5)
 *  6. printCertificate()            – single certificate of attendance
 *  7. printAllCertificates()        – batch certificates, one per page
 *  8. Convenience wrappers:
 *       printEmployees, printLeaveRecords, printTravelOrders, printDTRRecords,
 *       printTrackingRecords, printSignatories, printTrainings, printSchedules,
 *       printBirthdayCelebrants, printPayrollRecords, printAuditLogs
 */

/* ─────────────────────────────────────────────────────────────
   SHARED HELPERS
   ───────────────────────────────────────────────────────────── */

function geamhTimestamp() {
  return new Date().toLocaleString('en-PH', {
    year: 'numeric', month: 'long', day: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

function openPrintWindow(html, width = 1200, height = 800, delay = 300) {
  const w = window.open('', '_blank', `width=${width},height=${height}`)
  if (w) {
    w.document.write(html)
    w.document.close()
    w.focus()
    setTimeout(() => w.print(), delay)
  } else {
    alert('Please allow popups to print reports')
  }
}

/** Shared page/body styles used across all print documents */
const BASE_CSS = `
  @import url('https://fonts.googleapis.com/css2?family=Arial:wght@400;600;700&display=swap');
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: Arial, sans-serif; color: #000; background: #fff; }
  @media print {
    body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
    .no-print { display: none !important; }
  }
`

/* ─────────────────────────────────────────────────────────────
   1. GENERIC TABLE PRINT (base helper)
   ───────────────────────────────────────────────────────────── */
export function printTable({ title, headers, data, formatRow, filters = {}, dateRange = '' }) {
  const now = geamhTimestamp()
  const activeFilters = Object.entries(filters).filter(([, v]) => v)
  const filterHtml = activeFilters.length
    ? `<div class="filter-bar"><b>Filters:</b> ${activeFilters.map(([k, v]) => `${k}: ${v}`).join(' &nbsp;|&nbsp; ')}</div>`
    : ''
  const dateHtml = dateRange
    ? `<div class="filter-bar"><b>Period:</b> ${dateRange}</div>` : ''

  const html = `<!DOCTYPE html><html><head>
<meta charset="UTF-8"><title>${title}</title>
<style>
  ${BASE_CSS}
  @page { size: A4 landscape; margin: 12mm; }
  body { font-size: 9pt; padding: 0; }
  .doc-header { text-align: center; border-bottom: 3px solid #1a6b3c; padding-bottom: 12px; margin-bottom: 14px; }
  .doc-header img { height: 56px; margin-bottom: 6px; }
  .doc-header h1 { font-size: 16pt; color: #1a6b3c; }
  .doc-header p  { font-size: 9pt; color: #555; }
  .filter-bar { background: #eaf5ee; padding: 6px 10px; border-left: 3px solid #1a6b3c;
                margin-bottom: 8px; font-size: 8pt; }
  .record-count { font-weight: 700; color: #1a6b3c; margin-bottom: 6px; font-size: 8.5pt; }
  table { width: 100%; border-collapse: collapse; }
  th { background: #1a6b3c; color: #fff; padding: 7px 5px; font-size: 8.5pt;
       border: 1px solid #0d5230; text-align: left; }
  td { padding: 5px; border: 1px solid #ddd; font-size: 8.5pt; }
  tr:nth-child(even) td { background: #f0faf4; }
  .footer { margin-top: 16px; border-top: 1px solid #ccc; padding-top: 8px;
            text-align: center; font-size: 7.5pt; color: #888; }
</style></head><body>
<div class="doc-header">
  <img src="${window.location.origin}/GEAMH LOGO.png" alt="GEAMH" onerror="this.style.display='none'">
  <h1>${title}</h1>
  <p>General Emilio Aguinaldo Memorial Hospital &nbsp;·&nbsp; Human Resource Information System</p>
  <p style="font-size:8pt;color:#999;">Generated: ${now}</p>
</div>
${filterHtml}${dateHtml}
<div class="record-count">Total Records: ${data.length}</div>
<table>
  <thead><tr>${headers.map(h => `<th>${h}</th>`).join('')}</tr></thead>
  <tbody>
    ${data.map((row, i) => {
      const cells = formatRow(row, i)
      return `<tr>${cells.map(c => `<td>${c}</td>`).join('')}</tr>`
    }).join('')}
  </tbody>
</table>
<div class="footer">
  © ${new Date().getFullYear()} GEAMH HRIS — Confidential Document &nbsp;|&nbsp; ${now}
</div>
</body></html>`

  openPrintWindow(html)
}

/* ─────────────────────────────────────────────────────────────
   2. SCHEDULE OF DUTIES  (Images 1 & 3 format)
      – 31-day grid, grouped by employment type (GEAMH PERMANENT,
        GEAMH CASUAL, KPFP, KPFP CASUAL …)
      – Columns: NAME | 1…31 | No. of Days | Signature
      – Day-of-week row under the date numbers
      – Colored weekends (Sat/Sun = red header)
      – Group label rows (green bold text)
      – Legend + 3-column signature block
   ───────────────────────────────────────────────────────────── */
export function printScheduleOfDuties(schedules, options = {}) {
  const {
    department     = '',
    period         = '',
    periodStart    = null,      // JS Date or date string; used to compute correct day-of-week
    preparedBy     = '',
    preparedByTitle= '',
    approvedBy     = 'ALLAN MIRANDILLA',
    approvedByTitle= 'Records Officer I\nOIC-Personnel Section',
    notedBy        = 'NONIE JOHN L. DALISAY, MD, FPOGS, MBA',
    notedByTitle   = 'Provincial Health Officer II',
    hospital       = 'GENERAL EMILIO AGUINALDO MEMORIAL HOSPITAL',
    project        = 'Korea-Philippines Friendship Health Project',
    location       = 'Trece Martires City',
    showSignature  = true,
  } = options

  const periodLabel = period || new Date().toLocaleDateString('en-PH', { month: 'long', year: 'numeric' })

  /* Compute actual day-of-week for each date in the month */
  const days = Array.from({ length: 31 }, (_, i) => i + 1)
  const DOW_SHORT = ['SUN','MON','TUE','WED','THU','FRI','SAT']

  function getDow(dayNum) {
    if (periodStart) {
      const d = new Date(periodStart)
      d.setDate(dayNum)
      return DOW_SHORT[d.getDay()]
    }
    return DOW_SHORT[(dayNum - 1) % 7] // fallback approximation
  }

  /* Group schedules by their groupLabel / employmentStatus */
  const groupOrder = []
  const groups     = {}
  for (const s of schedules) {
    const grp = (s.groupLabel || s.employmentStatus || 'STAFF').toUpperCase()
    if (!groups[grp]) { groups[grp] = []; groupOrder.push(grp) }
    groups[grp].push(s)
  }

  /* Build rows */
  let bodyHtml = ''
  for (const grp of groupOrder) {
    bodyHtml += `<tr class="group-row"><td colspan="34"><span class="grp-label">${grp}</span></td></tr>`
    for (const emp of groups[grp]) {
      const sched = Array.isArray(emp.schedule) ? emp.schedule : []
      const numDays = emp.numDays ?? sched.filter(c => c && c !== 'O' && c !== '0').length
      const cells = days.map((_, i) => {
        const code = sched[i] !== undefined ? sched[i] : ''
        const upper = String(code).toUpperCase()
        const cls = upper === 'H' ? 'c-h'
          : upper === 'L' ? 'c-l'
          : upper === 'O' || upper === '0' ? 'c-o'
          : code ? 'c-w' : ''
        return `<td class="td-day ${cls}">${code}</td>`
      }).join('')
      const sigCell = showSignature ? `<td class="td-sig"></td>` : ''
      bodyHtml += `<tr>
        <td class="td-name">${emp.employeeName || ''}</td>
        ${cells}
        <td class="td-days">${numDays}</td>
        ${sigCell}
      </tr>`
    }
  }

  /* Day-of-week header row */
  const dowRow = days.map(d => {
    const dow = getDow(d)
    const isWknd = dow === 'SAT' || dow === 'SUN'
    return `<th class="th-day${isWknd ? ' th-wknd' : ''}">${dow}</th>`
  }).join('')

  const sigColHeader = showSignature ? `<th class="th-days" rowspan="2">Signature</th>` : ''
  const html = `<!DOCTYPE html><html><head>
<meta charset="UTF-8"><title>Schedule of Duties — ${department}</title>
<style>
  ${BASE_CSS}
  @page { size: A4 landscape; margin: 8mm 7mm; }
  body { font-size: 7.5pt; }
  .doc-header { text-align: center; margin-bottom: 6px; }
  .doc-header .hosp  { font-size: 10.5pt; font-weight: 700; text-transform: uppercase; }
  .doc-header .sub   { font-size: 8.5pt; }
  .doc-header .title { font-size: 10pt; font-weight: 700; text-decoration: underline; margin-top: 5px; }
  .doc-header .period{ font-size: 10pt; font-weight: 700; text-decoration: underline; }
  .dept-line { font-size: 8.5pt; margin: 4px 0; }
  table { border-collapse: collapse; width: 100%; }
  th, td { border: 1px solid #666; padding: 1px 2px; text-align: center; white-space: nowrap; }
  .th-name  { background: #d4d4d4; font-weight: 700; text-align: left;
              min-width: 115px; max-width: 135px; font-size: 7pt; }
  .td-name  { text-align: left; font-size: 7pt; padding: 1px 3px; }
  .th-day   { background: #1a6b3c; color: #fff; min-width: 13px; font-size: 6pt; font-weight: 600; }
  .th-wknd  { background: #c0392b !important; }
  .th-days  { background: #1a6b3c; color: #fff; min-width: 26px; font-size: 6pt; font-weight: 600; }
  .td-day   { font-size: 7pt; }
  .td-days  { font-weight: 700; font-size: 7pt; }
  .td-sig   { min-width: 52px; }
  .group-row td { background: #e6e6e6; padding: 2px 4px; }
  .grp-label { color: #b40000; font-weight: 700; font-size: 7.5pt; }
  /* shift colours */
  .c-w { background: #eafaf1; }
  .c-o { color: #c0392b; font-weight: 700; }
  .c-h { background: #fef3e2; color: #e67e22; font-weight: 700; }
  .c-l { background: #ebf5fb; color: #2980b9; font-weight: 700; }
  /* legend */
  .legend { margin-top: 7px; font-size: 7.5pt; display: flex; gap: 20px; flex-wrap: wrap; }
  .legend b { margin-right: 4px; }
  /* signatures */
  .sigs { display: flex; justify-content: space-between; margin-top: 18px; gap: 20px; }
  .sig-col { min-width: 140px; }
  .sig-role  { font-size: 7pt; color: #555; margin-bottom: 28px; }
  .sig-name  { font-size: 7.5pt; font-weight: 700; border-top: 1px solid #000;
               padding-top: 3px; min-width: 130px; }
  .sig-title { font-size: 6.5pt; color: #333; white-space: pre-line; }
</style></head><body>
<div class="doc-header">
  <div class="hosp">${hospital}</div>
  <div class="sub">${project}</div>
  <div class="sub">${location}</div>
  <div class="title">Schedule of Duties</div>
  <div class="period">${periodLabel}</div>
</div>
<div class="dept-line"><b>Department/Unit:</b> ${department}</div>
<table>
  <thead>
    <tr>
      <th class="th-name" rowspan="2">NAME OF EMPLOYEE</th>
      ${days.map(d => `<th class="th-day">${d}</th>`).join('')}
      <th class="th-days" rowspan="2">No. of<br>Days</th>
      ${sigColHeader}
    </tr>
    <tr>${dowRow}</tr>
  </thead>
  <tbody>${bodyHtml || `<tr><td colspan="34" style="text-align:center;padding:10px;color:#aaa;">No schedule data</td></tr>`}</tbody>
</table>

<div class="legend">
  <b>LEGEND:</b>
  <span>85 — 8:00am to 5:00pm</span>
  <span>O — Off Duty</span>
  <span>H — Holiday</span>
  <span>L — Leave / CTO</span>
</div>

${preparedBy || approvedBy || notedBy ? `
<div class="sigs">
  <div class="sig-col">
    <div class="sig-role">Prepared by:</div>
    <div class="sig-name">${preparedBy}</div>
    <div class="sig-title">${preparedByTitle}</div>
  </div>
  <div class="sig-col">
    <div class="sig-role">Approved by:</div>
    <div class="sig-name">${approvedBy}</div>
    <div class="sig-title">${approvedByTitle}</div>
  </div>
  <div class="sig-col">
    <div class="sig-role">Noted by:</div>
    <div class="sig-name">${notedBy}</div>
    <div class="sig-title">${notedByTitle}</div>
  </div>
</div>` : ''}
</body></html>`

  openPrintWindow(html, 1300, 850)
}

/* ─────────────────────────────────────────────────────────────
   3. NURSING SERVICE SCHEDULE  (Image 2 format)
      – Per-department, with multiple shift codes & colors
      – Full 31-day grid, colored day headers for weekends
      – Colored cell text per shift code
      – Extended legend (62=blue, 210=green, 106=red, 95, 84, 85, O, L)
   ───────────────────────────────────────────────────────────── */
export function printNursingSchedule(schedules, options = {}) {
  const {
    department      = '',
    subDepartment   = '',
    month           = '',           // e.g. "MAY 2026"
    periodStart     = null,
    preparedBy      = '',
    preparedByTitle = 'Administrative Aide III',
    approvedBy      = '',
    approvedByTitle = 'Nurse V / Chief Nurse',
    notedBy         = 'NONIE JOHN L. DALISAY, MD, FPOGS, MBA',
    notedByTitle    = 'Provincial Health Officer II',
    hospital        = 'GEN. EMILIO AGUINALDO MEMORIAL HOSPITAL',
    project         = 'Korea-Philippines Friendship Project Hospital',
    location        = 'Trece Martires City, Cavite',
    /**
     * shiftColors: map of shift code → { color, bg }
     * Defaults match the physical document (Image 2)
     */
    shiftColors     = {
      '62':  { color: '#2471a3', bg: '#ebf5fb' },   // blue
      '210': { color: '#1e8449', bg: '#eafaf1' },   // green
      '106': { color: '#c0392b', bg: '#fdf2f2' },   // red
      '95':  { color: '#7d3c98', bg: '#f5eef8' },   // purple
      '84':  { color: '#7d6608', bg: '#fefde7' },   // olive
      '85':  { color: '#1c1c1c', bg: '#fff' },       // black
      '610': { color: '#117a65', bg: '#e8f8f5' },   // dark teal
      '25':  { color: '#6e2f1a', bg: '#fdf0e8' },   // dark orange
      'O':   { color: '#c0392b', bg: '#fff' },       // red O
      'L':   { color: '#2980b9', bg: '#fff' },       // blue L
      'H':   { color: '#e67e22', bg: '#fef9e7' },   // orange H
    },
  } = options

  const DOW_SHORT = ['SUN','MON','TUE','WED','THU','FRI','SAT']
  const days = Array.from({ length: 31 }, (_, i) => i + 1)

  function getDow(dayNum) {
    if (periodStart) {
      const d = new Date(periodStart); d.setDate(dayNum)
      return DOW_SHORT[d.getDay()]
    }
    return DOW_SHORT[(dayNum - 1) % 7]
  }

  function cellStyle(code) {
    const upper = String(code || '').toUpperCase()
    if (!code) return ''
    const cfg = shiftColors[code] || shiftColors[upper] || null
    if (cfg) return `style="color:${cfg.color};background:${cfg.bg};font-weight:700;"`
    return ''
  }

  /* Table rows */
  const rowsHtml = schedules.map(emp => {
    const sched = Array.isArray(emp.schedule) ? emp.schedule : []
    const numDays = emp.numDays ?? sched.filter(c => c && String(c).toUpperCase() !== 'O' && c !== '0').length
    const cells = days.map((_, i) => {
      const code = sched[i] !== undefined ? sched[i] : ''
      return `<td class="td-day" ${cellStyle(code)}>${code}</td>`
    }).join('')
    return `<tr>
      <td class="td-name">${emp.employeeName || ''}</td>
      ${cells}
      <td class="td-days">${numDays}</td>
    </tr>`
  }).join('')

  const dowRow = days.map(d => {
    const dow = getDow(d)
    const isWknd = dow === 'SAT' || dow === 'SUN'
    return `<th class="th-day${isWknd ? ' th-wknd' : ''}">${dow}</th>`
  }).join('')

  const html = `<!DOCTYPE html><html><head>
<meta charset="UTF-8"><title>Nursing Schedule — ${department}</title>
<style>
  ${BASE_CSS}
  @page { size: A4 landscape; margin: 7mm 6mm; }
  body { font-size: 7pt; }
  .doc-header { text-align: center; margin-bottom: 5px; }
  .doc-header .hosp  { font-size: 9.5pt; font-weight: 700; text-transform: uppercase; }
  .doc-header .sub   { font-size: 7.5pt; color: #444; }
  .dept-block { display: flex; align-items: flex-start; gap: 8px;
                margin-bottom: 4px; font-size: 8pt; }
  .dept-block .lbl { font-weight: 700; }
  .month-tag { font-weight: 700; font-size: 9pt; color: #c0392b;
               border: 1px solid #c0392b; padding: 2px 6px;
               display: inline-block; margin-bottom: 4px; }
  table { border-collapse: collapse; width: 100%; }
  th, td { border: 1px solid #888; padding: 1px 1px; text-align: center; white-space: nowrap; }
  .th-name  { background: #bfbfbf; font-weight: 700; text-align: left;
              min-width: 100px; max-width: 120px; font-size: 6.5pt; }
  .td-name  { text-align: left; font-size: 6.5pt; padding: 1px 3px; }
  .th-day   { background: #1a6b3c; color: #fff; min-width: 12px; font-size: 5.5pt; font-weight: 600; }
  .th-wknd  { background: #c0392b !important; }
  .th-days  { background: #1a6b3c; color: #fff; min-width: 22px; font-size: 5.5pt; font-weight: 600; }
  .td-day   { font-size: 6.5pt; }
  .td-days  { font-weight: 700; font-size: 6.5pt; }
  /* legend */
  .legend { margin-top: 6px; font-size: 7pt; display: flex; gap: 14px; flex-wrap: wrap; }
  .legend-item { display: flex; align-items: center; gap: 3px; }
  .legend-box { display: inline-block; width: 10px; height: 10px; border: 1px solid #999; border-radius: 2px; }
  /* sigs */
  .sigs { display: flex; justify-content: space-between; margin-top: 16px; }
  .sig-col { min-width: 130px; }
  .sig-role  { font-size: 6.5pt; color: #555; margin-bottom: 22px; }
  .sig-name  { font-size: 7pt; font-weight: 700; border-top: 1px solid #000;
               padding-top: 3px; min-width: 120px; }
  .sig-title { font-size: 6pt; color: #333; }
</style></head><body>
<div class="doc-header">
  <div class="hosp">${hospital}</div>
  <div class="sub">${project}</div>
  <div class="sub">${location}</div>
  <div class="sub" style="margin-top:3px;font-weight:700;">Schedule of Duties ${month}</div>
</div>
<div class="dept-block">
  <span class="month-tag">${month}</span>
  <div>
    <div><span class="lbl">${department}</span></div>
    ${subDepartment ? `<div style="font-size:7.5pt;">${subDepartment}</div>` : ''}
  </div>
</div>
<table>
  <thead>
    <tr>
      <th class="th-name" rowspan="2">NAME OF EMPLOYEE</th>
      ${days.map(d => `<th class="th-day">${d}</th>`).join('')}
      <th class="th-days" rowspan="2">No. of<br>DAYS</th>
    </tr>
    <tr>${dowRow}</tr>
  </thead>
  <tbody>${rowsHtml || `<tr><td colspan="33" style="text-align:center;padding:10px;color:#aaa;">No schedule data</td></tr>`}</tbody>
</table>

<div class="legend">
  <b>LEGEND:</b>
  ${Object.entries(shiftColors).map(([code, cfg]) => `
    <span class="legend-item">
      <span class="legend-box" style="background:${cfg.bg};"></span>
      <span style="color:${cfg.color};font-weight:700;">${code}</span>
    </span>`).join('')}
  <span>&nbsp;O — Off Duty&nbsp;&nbsp;L — Leave/CTO&nbsp;&nbsp;H — Holiday</span>
</div>

<div class="sigs">
  <div class="sig-col">
    <div class="sig-role">Prepared by:</div>
    <div class="sig-name">${preparedBy}</div>
    <div class="sig-title">${preparedByTitle}</div>
  </div>
  <div class="sig-col">
    <div class="sig-role">Approved by:</div>
    <div class="sig-name">${approvedBy}</div>
    <div class="sig-title">${approvedByTitle}</div>
  </div>
  <div class="sig-col">
    <div class="sig-role">Noted by:</div>
    <div class="sig-name">${notedBy}</div>
    <div class="sig-title">${notedByTitle}</div>
  </div>
</div>
</body></html>`

  openPrintWindow(html, 1350, 860)
}

/* ─────────────────────────────────────────────────────────────
   4. TRANSMITTAL OF SCHEDULE  (Image 4 format)
      – Header: OFFICE OF THE PROVINCIAL HEALTH OFFICER / GEAMH / KPFH
      – Title: TRANSMITTAL OF SCHEDULE + month in red
      – Table with yellow alternating rows:
          NAME OF DEPARTMENT | PAGE NUMBER | NUMBER OF STAFF |
          DATE SUBMITTED | REMARKS
   ───────────────────────────────────────────────────────────── */
export function printTransmittalReport(departments = [], options = {}) {
  const {
    month        = new Date().toLocaleDateString('en-PH', { month: 'long', year: 'numeric' }).toUpperCase(),
    dateStamped  = '',   // top-right date stamp  e.g. "2 0 APR 2026"
    hospital1    = 'OFFICE OF THE PROVINCIAL HEALTH OFFICER',
    hospital2    = 'GENERAL EMILIO AGUINALDO MEMORIAL HOSPITAL',
    hospital3    = 'KOREA-PHILIPPINES FRIENDSHIP HOSPITAL',
  } = options

  const rowsHtml = departments.map((dept, idx) => {
    const odd = idx % 2 === 0
    const bg  = odd ? '#ffd700' : '#fff9c4'  // yellow shades matching the photo
    return `<tr style="background:${bg};">
      <td class="td-dept"><b>${dept.department || ''}</b></td>
      <td class="td-center">${dept.pageNumber ?? idx + 1}</td>
      <td class="td-center">${dept.staffCount ?? ''}</td>
      <td class="td-center">${dept.dateSubmitted
        ? new Date(dept.dateSubmitted).toLocaleDateString('en-PH', { month: 'short', day: 'numeric', year: 'numeric' })
        : ''}</td>
      <td class="td-remarks">${dept.remarks || ''}</td>
    </tr>`
  }).join('')

  const html = `<!DOCTYPE html><html><head>
<meta charset="UTF-8"><title>Transmittal of Schedule — ${month}</title>
<style>
  ${BASE_CSS}
  @page { size: A4 portrait; margin: 14mm; }
  body { font-size: 10pt; }
  .stamp { position: absolute; top: 14mm; right: 14mm; font-size: 8pt; color: #555; }
  .doc-header { text-align: center; margin-bottom: 20px; }
  .doc-header h1 { font-size: 11.5pt; font-weight: 700; text-transform: uppercase; line-height: 1.4; }
  .doc-header h2 { font-size: 13pt; font-weight: 700; margin-top: 10px; }
  .doc-header h3 { font-size: 13pt; font-weight: 700; color: #c0392b; margin-top: 4px; }
  table { width: 100%; border-collapse: collapse; border: 2px solid #000; }
  thead th { background: #a8d4f5; border: 1px solid #000; padding: 8px 6px;
             font-size: 10pt; font-weight: 700; text-align: center; text-transform: uppercase; }
  td { border: 1px solid #000; padding: 6px 8px; font-size: 9.5pt; }
  .td-dept   { text-align: left; }
  .td-center { text-align: center; }
  .td-remarks{ text-align: left; }
</style></head><body>
${dateStamped ? `<div class="stamp">${dateStamped}</div>` : ''}
<div class="doc-header">
  <h1>${hospital1}<br>${hospital2}<br>${hospital3}</h1>
  <h2>TRANSMITTAL OF SCHEDULE</h2>
  <h3>${month}</h3>
</div>
<table>
  <thead>
    <tr>
      <th style="width:42%;">NAME OF DEPARTMENT</th>
      <th style="width:12%;">PAGE NUMBER</th>
      <th style="width:14%;">NUMBER OF STAFF</th>
      <th style="width:16%;">DATE SUBMITTED</th>
      <th style="width:16%;">REMARKS</th>
    </tr>
  </thead>
  <tbody>
    ${rowsHtml || `<tr><td colspan="5" style="text-align:center;padding:14px;color:#aaa;">No departments listed</td></tr>`}
  </tbody>
</table>
</body></html>`

  openPrintWindow(html, 900, 1100)
}

/* ─────────────────────────────────────────────────────────────
   5. TRAINING ATTENDEES LIST  (Image 5 / original code format)
      – Logo + hospital name header
      – Green underline + "TRAINING ATTENDEES LIST" title
      – Info box: Title, Category, Instructor | Date, Venue, Total Participants
      – Table: No. | Name | Position | Department
      – Signature block at bottom
   ───────────────────────────────────────────────────────────── */
export function printTrainingAttendees(training, participants = []) {
  const now = new Date().toLocaleDateString('en-PH', {
    year: 'numeric', month: 'long', day: 'numeric'
  })

  const rowsHtml = participants.map((p, i) => `
    <tr>
      <td class="center">${i + 1}</td>
      <td>${p.last_name || ''}, ${p.first_name || ''}</td>
      <td>${p.position || '—'}</td>
      <td>${p.department || '—'}</td>
    </tr>`).join('')

  const html = `<!DOCTYPE html><html><head>
<meta charset="UTF-8"><title>Training Attendees List</title>
<style>
  ${BASE_CSS}
  @page { size: A4 portrait; margin: 12mm; }
  body { font-size: 10pt; padding: 20px; }
  .report-container { border: 2px solid #1f7a45; padding: 20px; border-radius: 8px; }
  /* HEADER */
  .header { display: flex; align-items: center; justify-content: center; gap: 16px;
            border-bottom: 3px solid #1f7a45; padding-bottom: 14px; margin-bottom: 20px; }
  .logo { width: 70px; height: 70px; object-fit: contain; }
  .header-text { text-align: center; }
  .header-text h1 { font-size: 16pt; color: #14532d; font-weight: 700; text-transform: uppercase; }
  .header-text p  { font-size: 9pt; color: #666; margin-top: 3px; }
  .report-title { margin-top: 8px; font-size: 13pt; font-weight: 700; color: #1f7a45;
                  text-transform: uppercase; letter-spacing: 1px; }
  /* INFO SECTION */
  .info-section { margin-bottom: 20px; }
  .info-header { background: none; border-bottom: 2px solid #1f7a45;
                 padding: 4px 0; font-size: 10pt; font-weight: 700; color: #1f7a45;
                 margin-bottom: 8px; }
  .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 8px 24px; font-size: 9pt; }
  .info-item { display: flex; gap: 6px; }
  .info-label { font-weight: 700; color: #14532d; min-width: 120px; }
  /* TABLE */
  table { width: 100%; border-collapse: collapse; margin-top: 6px; }
  thead th { background: #14532d; color: #fff; padding: 10px 8px;
             font-size: 9.5pt; border: 1px solid #0d3b21; text-transform: uppercase; }
  tbody td { border: 1px solid #dcdcdc; padding: 8px; font-size: 9pt; }
  tbody tr:nth-child(even) td { background: #f7faf8; }
  .center { text-align: center; }
  /* SIGNATURE */
  .signature-section { margin-top: 40px; display: flex; justify-content: space-between; gap: 30px; }
  .signature-box { width: 45%; text-align: center; }
  .signature-line { border-top: 1px solid #333; margin-top: 50px; padding-top: 6px;
                    font-weight: 600; font-size: 9pt; }
  .signature-label { font-size: 8pt; color: #666; margin-top: 2px; }
  /* FOOTER */
  .footer { margin-top: 24px; border-top: 1px solid #ccc; padding-top: 8px;
            text-align: center; font-size: 8pt; color: #777; }
</style></head><body>
<div class="report-container">
  <div class="header">
    <img src="${window.location.origin}/GEAMH LOGO.png" alt="GEAMH Logo" class="logo" onerror="this.style.display='none'">
    <div class="header-text">
      <h1>General Emilio Aguinaldo Memorial Hospital</h1>
      <p>Human Resource Information System</p>
      <div class="report-title">Training Attendees List</div>
    </div>
  </div>

  <div class="info-section">
    <div class="info-grid">
      <div class="info-item"><span class="info-label">Training Title:</span><span>${training.title || '—'}</span></div>
      <div class="info-item"><span class="info-label">Date:</span><span>${training.dateFrom || '—'}</span></div>
      <div class="info-item"><span class="info-label">Category:</span><span>${training.category || '—'}</span></div>
      <div class="info-item"><span class="info-label">Venue:</span><span>${training.venue || '—'}</span></div>
      <div class="info-item"><span class="info-label">Instructor:</span><span>${training.instructor || '—'}</span></div>
      <div class="info-item"><span class="info-label">Total Participants:</span>
        <span>${participants.length} / ${training.maxParticipants || 0}</span></div>
    </div>
  </div>

  <table>
    <thead>
      <tr>
        <th style="width:50px;">No.</th>
        <th>Name</th>
        <th>Position</th>
        <th>Department</th>
      </tr>
    </thead>
    <tbody>
      ${rowsHtml || `<tr><td colspan="4" class="center" style="padding:18px;color:#999;">No participants available</td></tr>`}
    </tbody>
  </table>

  <div class="signature-section">
    <div class="signature-box">
      <div class="signature-line">HR Officer</div>
      <div class="signature-label">Prepared By</div>
    </div>
    <div class="signature-box">
      <div class="signature-line">HR Manager</div>
      <div class="signature-label">Approved By</div>
    </div>
  </div>

  <div class="footer">
    <p>© ${new Date().getFullYear()} GEAMH HRIS — Confidential Document</p>
    <p>Generated on ${now}</p>
  </div>
</div>
</body></html>`

  openPrintWindow(html, 900, 1000)
}

/* ─────────────────────────────────────────────────────────────
   6. CERTIFICATE OF ATTENDANCE  (single)
   ───────────────────────────────────────────────────────────── */
export function printCertificate(training, participant) {
  const dateStr = training.dateFrom
    ? new Date(training.dateFrom).toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' })
    : '—'
  const dateTo = training.dateTo && training.dateTo !== training.dateFrom
    ? ' to ' + new Date(training.dateTo).toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' })
    : ''
  const fullName = `${participant.first_name || ''} ${participant.last_name || ''}`.trim()
  const position = participant.position || ''
  const department = participant.department || ''
  const now = new Date().toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' })

  const html = `<!DOCTYPE html><html><head>
<meta charset="UTF-8"><title>Certificate — ${fullName}</title>
<style>
  ${BASE_CSS}
  @page { size: A4 landscape; margin: 0; }
  body { font-family: 'Times New Roman', Times, serif;
         width: 297mm; height: 210mm; display: flex; align-items: center; justify-content: center; }
  .cert { width: 270mm; height: 190mm; border: 12px double #1a6b3c;
          outline: 3px solid #1a6b3c; outline-offset: -18px;
          padding: 18mm 22mm; display: flex; flex-direction: column;
          align-items: center; justify-content: space-between; position: relative;
          background: linear-gradient(135deg, #f9fff9 0%, #fff 50%, #f0f7ff 100%); }
  .cert-top { text-align: center; width: 100%; }
  .logo-row { display: flex; align-items: center; justify-content: center; gap: 16px; margin-bottom: 8px; }
  .logo { width: 64px; height: 64px; object-fit: contain; }
  .hosp-name { font-size: 13pt; font-weight: 700; color: #1a6b3c; line-height: 1.3; }
  .hosp-sub  { font-size: 9pt; color: #555; }
  .cert-title { font-size: 28pt; font-weight: 700; color: #1a6b3c; letter-spacing: 3px;
                text-transform: uppercase; margin: 10px 0 4px;
                text-shadow: 1px 1px 2px rgba(0,0,0,.08); }
  .cert-subtitle { font-size: 11pt; color: #555; letter-spacing: 1px; margin-bottom: 14px; }
  .cert-body { text-align: center; width: 100%; }
  .cert-presented { font-size: 11pt; color: #555; margin-bottom: 6px; }
  .cert-name { font-size: 26pt; color: #1a6b3c; font-style: italic;
               border-bottom: 2px solid #1a6b3c; display: inline-block;
               padding: 0 20px 4px; margin: 4px 0 8px; min-width: 280px; }
  .cert-position { font-size: 10pt; color: #666; margin-bottom: 14px; }
  .cert-text { font-size: 11pt; color: #333; line-height: 1.8; max-width: 200mm; margin: 0 auto; }
  .cert-training { font-weight: 700; color: #1a6b3c; font-size: 13pt; }
  .cert-date { font-style: italic; color: #555; }
  .cert-bottom { display: flex; justify-content: space-between; align-items: flex-end;
                 width: 100%; margin-top: 10px; }
  .sig-block { text-align: center; min-width: 120px; }
  .sig-line { border-top: 1px solid #333; padding-top: 4px; font-size: 9pt;
              font-weight: 700; color: #1a6b3c; }
  .sig-label { font-size: 8pt; color: #666; }
  .cert-seal { width: 70px; height: 70px; border-radius: 50%; border: 3px solid #1a6b3c;
               display: flex; align-items: center; justify-content: center;
               font-size: 7pt; color: #1a6b3c; text-align: center; font-weight: 700;
               line-height: 1.2; padding: 6px; }
  .cert-no { font-size: 7pt; color: #aaa; position: absolute; bottom: 8mm; right: 12mm; }
</style></head><body>
<div class="cert">
  <div class="cert-top">
    <div class="logo-row">
      <img src="${window.location.origin}/GEAMH LOGO.png" alt="GEAMH" class="logo" onerror="this.style.display='none'">
      <div>
        <div class="hosp-name">General Emilio Aguinaldo Memorial Hospital</div>
        <div class="hosp-sub">Korea-Philippines Friendship Health Project · Trece Martires City</div>
      </div>
    </div>
    <div class="cert-title">Certificate of Attendance</div>
    <div class="cert-subtitle">Human Resource Information System</div>
  </div>
  <div class="cert-body">
    <div class="cert-presented">This is to certify that</div>
    <div class="cert-name">${fullName}</div>
    <div class="cert-position">${position}${department ? ' · ' + department : ''}</div>
    <div class="cert-text">
      has successfully attended and completed the training seminar on<br>
      <span class="cert-training">"${training.title || 'Training Seminar'}"</span><br>
      held on <span class="cert-date">${dateStr}${dateTo}</span>
      ${training.venue ? ` at <span class="cert-date">${training.venue}</span>` : ''}.
    </div>
  </div>
  <div class="cert-bottom">
    <div class="sig-block">
      <div style="height:40px;"></div>
      <div class="sig-line">${training.instructor || '___________________'}</div>
      <div class="sig-label">Training Facilitator / Instructor</div>
    </div>
    <div class="cert-seal">GEAMH<br>HRIS<br>OFFICIAL</div>
    <div class="sig-block">
      <div style="height:40px;"></div>
      <div class="sig-line">NONIE JOHN L. DALISAY, MD</div>
      <div class="sig-label">Provincial Health Officer II</div>
    </div>
  </div>
  <div class="cert-no">Issued: ${now}</div>
</div>
</body></html>`

  openPrintWindow(html, 1100, 800)
}

/* ─────────────────────────────────────────────────────────────
   7. BATCH CERTIFICATES  (one per page)
   ───────────────────────────────────────────────────────────── */
export function printAllCertificates(training, participants = []) {
  if (!participants.length) { alert('No participants to print certificates for.'); return }

  const dateStr = training.dateFrom
    ? new Date(training.dateFrom).toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' })
    : '—'
  const dateTo = training.dateTo && training.dateTo !== training.dateFrom
    ? ' to ' + new Date(training.dateTo).toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' })
    : ''
  const now = new Date().toLocaleDateString('en-PH', { year: 'numeric', month: 'long', day: 'numeric' })

  const pages = participants.map((p, idx) => {
    const fullName  = `${p.first_name || ''} ${p.last_name || ''}`.trim()
    const position  = p.position || ''
    const department= p.department || ''
    return `
    <div class="cert${idx === 0 ? '' : ' page-break'}">
      <div class="cert-top">
        <div class="logo-row">
          <img src="${window.location.origin}/GEAMH LOGO.png" alt="GEAMH" class="logo" onerror="this.style.display='none'">
          <div>
            <div class="hosp-name">General Emilio Aguinaldo Memorial Hospital</div>
            <div class="hosp-sub">Korea-Philippines Friendship Health Project · Trece Martires City</div>
          </div>
        </div>
        <div class="cert-title">Certificate of Attendance</div>
        <div class="cert-subtitle">Human Resource Information System</div>
      </div>
      <div class="cert-body">
        <div class="cert-presented">This is to certify that</div>
        <div class="cert-name">${fullName}</div>
        <div class="cert-position">${position}${department ? ' · ' + department : ''}</div>
        <div class="cert-text">
          has successfully attended and completed the training seminar on<br>
          <span class="cert-training">"${training.title || 'Training Seminar'}"</span><br>
          held on <span class="cert-date">${dateStr}${dateTo}</span>
          ${training.venue ? ` at <span class="cert-date">${training.venue}</span>` : ''}.
        </div>
      </div>
      <div class="cert-bottom">
        <div class="sig-block">
          <div style="height:40px;"></div>
          <div class="sig-line">${training.instructor || '___________________'}</div>
          <div class="sig-label">Training Facilitator / Instructor</div>
        </div>
        <div class="cert-seal">GEAMH<br>HRIS<br>OFFICIAL</div>
        <div class="sig-block">
          <div style="height:40px;"></div>
          <div class="sig-line">NONIE JOHN L. DALISAY, MD</div>
          <div class="sig-label">Provincial Health Officer II</div>
        </div>
      </div>
      <div class="cert-no">Issued: ${now}</div>
    </div>`
  }).join('')

  const html = `<!DOCTYPE html><html><head>
<meta charset="UTF-8"><title>Certificates — ${training.title}</title>
<style>
  ${BASE_CSS}
  @page { size: A4 landscape; margin: 0; }
  body { font-family: 'Times New Roman', Times, serif; }
  .cert { width: 297mm; height: 210mm; border: 12px double #1a6b3c;
          outline: 3px solid #1a6b3c; outline-offset: -18px; padding: 15mm 22mm;
          display: flex; flex-direction: column; align-items: center;
          justify-content: space-between; position: relative;
          background: linear-gradient(135deg, #f9fff9 0%, #fff 50%, #f0f7ff 100%); }
  .page-break { page-break-before: always; }
  .cert-top { text-align: center; width: 100%; }
  .logo-row { display: flex; align-items: center; justify-content: center; gap: 16px; margin-bottom: 6px; }
  .logo { width: 56px; height: 56px; object-fit: contain; }
  .hosp-name { font-size: 12pt; font-weight: 700; color: #1a6b3c; line-height: 1.3; }
  .hosp-sub  { font-size: 8pt; color: #555; }
  .cert-title { font-size: 26pt; font-weight: 700; color: #1a6b3c; letter-spacing: 3px;
                text-transform: uppercase; margin: 8px 0 3px; }
  .cert-subtitle { font-size: 10pt; color: #555; letter-spacing: 1px; margin-bottom: 10px; }
  .cert-body { text-align: center; width: 100%; }
  .cert-presented { font-size: 10pt; color: #555; margin-bottom: 4px; }
  .cert-name { font-size: 24pt; color: #1a6b3c; font-style: italic;
               border-bottom: 2px solid #1a6b3c; display: inline-block;
               padding: 0 20px 3px; margin: 3px 0 6px; min-width: 260px; }
  .cert-position { font-size: 9pt; color: #666; margin-bottom: 10px; }
  .cert-text { font-size: 10pt; color: #333; line-height: 1.8; max-width: 200mm; margin: 0 auto; }
  .cert-training { font-weight: 700; color: #1a6b3c; font-size: 12pt; }
  .cert-date { font-style: italic; color: #555; }
  .cert-bottom { display: flex; justify-content: space-between; align-items: flex-end;
                 width: 100%; margin-top: 8px; }
  .sig-block { text-align: center; min-width: 120px; }
  .sig-line { border-top: 1px solid #333; padding-top: 4px; font-size: 9pt; font-weight: 700; color: #1a6b3c; }
  .sig-label { font-size: 8pt; color: #666; }
  .cert-seal { width: 64px; height: 64px; border-radius: 50%; border: 3px solid #1a6b3c;
               display: flex; align-items: center; justify-content: center;
               font-size: 7pt; color: #1a6b3c; text-align: center; font-weight: 700;
               line-height: 1.2; padding: 6px; }
  .cert-no { font-size: 7pt; color: #aaa; position: absolute; bottom: 6mm; right: 10mm; }
</style></head><body>${pages}</body></html>`

  openPrintWindow(html, 1100, 800, 400)
}

/* ─────────────────────────────────────────────────────────────
   8. CONVENIENCE WRAPPERS (standard A4 landscape table reports)
   ───────────────────────────────────────────────────────────── */

export function printEmployees(employees, filters = {}) {
  printTable({
    title: 'Employee Masterlist Report',
    headers: ['#', 'Employee No', 'Name', 'Department', 'Position', 'Status', 'Employment Type'],
    data: employees,
    formatRow: (emp, i) => [
      i + 1,
      emp.employeeNo || '—',
      `${emp.lastName}, ${emp.firstName} ${emp.middleName || ''}`.trim(),
      emp.department || '—',
      emp.position || '—',
      emp.status || 'Active',
      emp.employmentType || '—'
    ],
    filters
  })
}

export function printLeaveRecords(records, filters = {}) {
  printTable({
    title: 'Leave Records Report',
    headers: ['#', 'Employee', 'Leave Type', 'Date From', 'Date To', 'Days', 'Status', 'Approved By'],
    data: records,
    formatRow: (rec, i) => [
      i + 1,
      rec.employeeName || '—',
      rec.leaveType || '—',
      rec.dateFrom || '—',
      rec.dateTo || '—',
      rec.days || '0',
      rec.status || 'Pending',
      rec.approvedBy || '—'
    ],
    filters
  })
}

export function printTravelOrders(orders, filters = {}) {
  printTable({
    title: 'Travel Orders Report',
    headers: ['#', 'Employee', 'Destination', 'Purpose', 'Date From', 'Date To', 'Days', 'Status'],
    data: orders,
    formatRow: (order, i) => [
      i + 1,
      order.employeeName || '—',
      order.destination || '—',
      order.purpose || '—',
      order.dateFrom || '—',
      order.dateTo || '—',
      order.days || '0',
      order.status || 'Pending'
    ],
    filters
  })
}

export function printDTRRecords(records, filters = {}) {
  printTable({
    title: 'DTR Transmittal Report',
    headers: ['#', 'Employee', 'Period', 'Department', 'Type', 'Status', 'Submitted', 'Verified By'],
    data: records,
    formatRow: (rec, i) => [
      i + 1,
      rec.employeeName || '—',
      rec.period || '—',
      rec.department || '—',
      rec.transmittalType || '—',
      rec.status || 'Pending',
      rec.dateSubmitted || '—',
      rec.verifiedBy || '—'
    ],
    filters
  })
}

export function printTrackingRecords(records, filters = {}, direction = 'Receiving') {
  printTable({
    title: `Document Tracking Report — ${direction}`,
    headers: ['#', 'Document Type', 'Doc No', 'From Office', 'To Office', 'Date Forwarded', 'Date Received', 'Status'],
    data: records,
    formatRow: (rec, i) => [
      i + 1,
      rec.docType || '—',
      rec.docNo || '—',
      rec.fromOffice || '—',
      rec.toOffice || '—',
      rec.dateForwarded || '—',
      rec.dateReceived || '—',
      rec.status || 'Pending'
    ],
    filters
  })
}

export function printSignatories(signatories, filters = {}) {
  printTable({
    title: 'Authorized Signatories Report',
    headers: ['#', 'Name', 'Position', 'Role', 'Department', 'Status', 'Order'],
    data: signatories,
    formatRow: (sig, i) => [
      i + 1,
      sig.name || '—',
      sig.position || '—',
      sig.role || '—',
      sig.department || '—',
      sig.active ? 'Active' : 'Inactive',
      sig.order || '—'
    ],
    filters
  })
}

export function printTrainings(trainings, filters = {}) {
  printTable({
    title: 'Trainings Report',
    headers: ['#', 'Title', 'Category', 'Instructor', 'Venue', 'Start Date', 'End Date', 'Participants', 'Status'],
    data: trainings,
    formatRow: (t, i) => [
      i + 1,
      t.title || '—',
      t.category || '—',
      t.instructor || '—',
      t.venue || '—',
      t.startDate || '—',
      t.endDate || '—',
      `${t.enrolledCount || 0}/${t.maxParticipants || 0}`,
      t.status || 'Upcoming'
    ],
    filters
  })
}

export function printSchedules(schedules, filters = {}) {
  printTable({
    title: 'Employee Schedules Report',
    headers: ['#', 'Employee No', 'Employee Name', 'Department', 'Shift', 'Shift Time', 'Days', 'Effective Date'],
    data: schedules,
    formatRow: (s, i) => [
      i + 1,
      s.employeeNo || '—',
      s.employeeName || '—',
      s.department || '—',
      s.shift || '—',
      s.shiftTime || '—',
      (s.days || []).join(', ') || '—',
      s.effectiveDate || '—'
    ],
    filters
  })
}

export function printBirthdayCelebrants(celebrants, month = '') {
  printTable({
    title: `Birthday Celebrants Report${month ? ` — ${month}` : ''}`,
    headers: ['#', 'Employee No', 'Name', 'Department', 'Birthday', 'Age', 'Contact'],
    data: celebrants,
    formatRow: (emp, i) => [
      i + 1,
      emp.employeeNo || '—',
      `${emp.lastName}, ${emp.firstName}`,
      emp.department || '—',
      emp.birthday || '—',
      emp.age || '—',
      emp.contactNumber || '—'
    ],
    filters: month ? { Month: month } : {}
  })
}

export function printPayrollRecords(records, filters = {}) {
  printTable({
    title: 'Payroll Records Report',
    headers: ['#', 'Employee', 'Period', 'Basic Pay', 'Deductions', 'Net Pay', 'Status'],
    data: records,
    formatRow: (rec, i) => [
      i + 1,
      rec.employeeName || '—',
      rec.period || '—',
      rec.basicPay ? `₱${parseFloat(rec.basicPay).toLocaleString('en-PH', { minimumFractionDigits: 2 })}` : '—',
      rec.totalDeductions ? `₱${parseFloat(rec.totalDeductions).toLocaleString('en-PH', { minimumFractionDigits: 2 })}` : '—',
      rec.netPay ? `₱${parseFloat(rec.netPay).toLocaleString('en-PH', { minimumFractionDigits: 2 })}` : '—',
      rec.status || 'Pending'
    ],
    filters
  })
}

export function printAuditLogs(logs, filters = {}) {
  printTable({
    title: 'Audit History Report',
    headers: ['#', 'Timestamp', 'User', 'Action', 'Module', 'Details', 'Status'],
    data: logs,
    formatRow: (log, i) => [
      i + 1,
      new Date(log.timestamp).toLocaleString('en-PH'),
      log.userName || '—',
      log.action || '—',
      log.module || '—',
      (log.details || '—').substring(0, 50) + ((log.details?.length ?? 0) > 50 ? '…' : ''),
      log.status || 'OK'
    ],
    filters
  })
}

/**
 * Print individual employee schedule
 */
export function printIndividualSchedule(schedule, options = {}) {
  const { title = 'Employee Schedule', includeLegend = true } = options
  
  printTable({
    title,
    headers: ['#', 'Employee No', 'Employee Name', 'Department', 'Shift', 'Shift Time', 'Days', 'Effective Date'],
    data: [schedule],
    formatRow: (sched, index) => [
      index + 1,
      sched.employeeNo || '—',
      sched.employeeName || '—',
      sched.department || '—',
      sched.shift || '—',
      sched.shiftTime || '—',
      (sched.days || []).join(', ') || '—',
      sched.effectiveDate || '—'
    ]
  })
}

/**
 * Print department schedule
 */
export function printDepartmentSchedule(schedules, options = {}) {
  const { title = 'Department Schedule', department = '', dateRange = '' } = options
  
  printTable({
    title: `${title}${department ? ` — ${department}` : ''}`,
    headers: ['#', 'Employee No', 'Employee Name', 'Department', 'Shift', 'Shift Time', 'Days', 'Effective Date'],
    data: schedules,
    formatRow: (sched, index) => [
      index + 1,
      sched.employeeNo || '—',
      sched.employeeName || '—',
      sched.department || '—',
      sched.shift || '—',
      sched.shiftTime || '—',
      (sched.days || []).join(', ') || '—',
      sched.effectiveDate || '—'
    ],
    dateRange
  })
}

/* ─────────────────────────────────────────────────────────────
   DEFAULT EXPORT
   ───────────────────────────────────────────────────────────── */
export default {
  printTable,
  printScheduleOfDuties,
  printNursingSchedule,
  printTransmittalReport,
  printTrainingAttendees,
  printCertificate,
  printAllCertificates,
  printEmployees,
  printLeaveRecords,
  printTravelOrders,
  printDTRRecords,
  printTrackingRecords,
  printSignatories,
  printTrainings,
  printSchedules,
  printBirthdayCelebrants,
  printPayrollRecords,
  printAuditLogs,
}
