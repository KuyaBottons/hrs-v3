import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

import Login from '@/views/Login.vue'
import Signup from '@/views/Signup.vue'
import Dashboard from '@/views/Dashboard.vue'
import EmployeeMasterlist from '@/views/employees/EmployeeMasterlist.vue'
import EmployeeForm from '@/views/employees/EmployeeForm.vue'
import BirthdayCelebrants from '@/views/employees/BirthdayCelebrants.vue'
import PRCLicenses from '@/views/employees/PRCLicenses.vue'
import DTRTransmittal from '@/views/dtr/DTRTransmittal.vue'
import LeaveManagement from '@/views/leave/LeaveManagement.vue'
import TOManagement from '@/views/to/TOManagement.vue'
import Verification from '@/views/verification/Verification.vue'
import TrackingReceiving from '@/views/tracking/TrackingReceiving.vue'
import Signatories from '@/views/signatories/Signatories.vue'
import AuditTransmittal from '@/views/audit/AuditTransmittal.vue'
import ScheduleDatabase from '@/views/schedule/ScheduleDatabase.vue'
import AIScanningTools from '@/views/ai/AIScanningTools.vue'
import AccountManagement from '@/views/accounts/AccountManagement.vue'
import TrainingsManagement from '@/views/trainings/TrainingsManagement.vue'
import DepartmentManagement from '@/views/departments/DepartmentManagement.vue'
import AuditHistory from '@/views/admin/AuditHistory.vue'
import VersionHistory from '@/views/admin/VersionHistory.vue'
import UserManual from '@/views/admin/UserManual.vue'
import DiosAccount from '@/views/admin/DiosAccount.vue'
import DiosSystemControl from '@/views/admin/DiosSystemControl.vue'
import PasswordResetRequests from '@/views/admin/PasswordResetRequests.vue'
import PayrollMasterlist from '@/views/payroll/PayrollMasterlist.vue'

const routes = [
  // ── Public ──────────────────────────────────────────────────────────────────
  { path: '/login',  name: 'Login',  component: Login,  meta: { public: true } },
  { path: '/signup', name: 'Signup', component: Signup, meta: { public: true, disabled: true } },

  // ── Core ─────────────────────────────────────────────────────────────────────
  { path: '/', name: 'Dashboard', component: Dashboard },

  // ── Employees ────────────────────────────────────────────────────────────────
  { path: '/employees',              name: 'EmployeeMasterlist', component: EmployeeMasterlist },
  { path: '/employees/new',          name: 'EmployeeNew',        component: EmployeeForm },
  { path: '/employees/:id/edit',     name: 'EmployeeEdit',       component: EmployeeForm },
  // Eye icon → view-only mode (read-only EmployeeForm)
  { path: '/employees/:id/view',     name: 'EmployeeView',       component: EmployeeForm,
    meta: { viewOnly: true } },
  { path: '/employees/birthdays',    name: 'BirthdayCelebrants', component: BirthdayCelebrants },
  { path: '/employees/prc-licenses', name: 'PRCLicenses',        component: PRCLicenses },

  // ── HR Modules ───────────────────────────────────────────────────────────────
  { path: '/dtr',          name: 'DTRTransmittal',    component: DTRTransmittal },
  { path: '/leave',        name: 'LeaveManagement',   component: LeaveManagement },
  { path: '/to',           name: 'TOManagement',      component: TOManagement },
  { path: '/verification', name: 'Verification',      component: Verification },
  { path: '/tracking',     name: 'TrackingReceiving', component: TrackingReceiving },
  { path: '/signatories',  name: 'Signatories',       component: Signatories },
  { path: '/audit',        name: 'AuditTransmittal',  component: AuditTransmittal },
  { path: '/schedule',     name: 'ScheduleDatabase',  component: ScheduleDatabase },
  { path: '/trainings',    name: 'TrainingsManagement', component: TrainingsManagement },
  { path: '/departments',  name: 'DepartmentManagement', component: DepartmentManagement },
  { path: '/payroll',      name: 'PayrollMasterlist', component: PayrollMasterlist },

  // ── Tools ────────────────────────────────────────────────────────────────────
  { path: '/ai-scanning', name: 'AIScanningTools', component: AIScanningTools },

  // ── Admin (adminOrDios) ───────────────────────────────────────────────────────
  { path: '/accounts',       name: 'AccountManagement', component: AccountManagement,
    meta: { adminOrDios: true } },
  { path: '/audit-trail',    name: 'AuditHistory',      component: AuditHistory,
    meta: { adminOrDios: true } },
  { path: '/version-history',name: 'VersionHistory',    component: VersionHistory,
    meta: { adminOrDios: true } },
  { path: '/user-manual',    name: 'UserManual',        component: UserManual },
  { path: '/dios-account',   name: 'DiosAccount',       component: DiosAccount,
    meta: { adminOrDios: true } },

  // ── DIOS only ─────────────────────────────────────────────────────────────────
  { path: '/dios-control',    name: 'DiosSystemControl',    component: DiosSystemControl,
    meta: { diosOnly: true } },
  { path: '/password-resets', name: 'PasswordResetRequests', component: PasswordResetRequests,
    meta: { diosOnly: true } },

  // ── Catch-all → redirect to dashboard ────────────────────────────────────────
  { path: '/:pathMatch(.*)*', redirect: '/' },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

router.beforeEach((to, _from, next) => {
  const auth = useAuthStore()

  if (!to.meta.public && !auth.isLoggedIn) {
    return next('/login')
  }
  if (to.path === '/login' && auth.isLoggedIn) {
    return next('/')
  }
  // Signup is disabled — only DIOS can create accounts via Account Management
  if (to.path === '/signup') {
    return next(auth.isLoggedIn ? '/' : '/login')
  }

  // Section Admin: only allowed routes
  if (auth.isLoggedIn && auth.isSectionAdmin) {
    const allowed = ['/', '/schedule', '/user-manual', '/employees/prc-licenses']
    const isAllowed = allowed.some(p => to.path === p || to.path.startsWith(p + '/'))
    if (!isAllowed) return next('/')
  }

  // Admin or DIOS only routes — allow Super Admin, Admin, DIOS, and IT roles
  if (to.meta.adminOrDios && auth.isLoggedIn) {
    const allowed = ['Super Admin', 'Admin', 'DIOS', 'IT']
    if (!allowed.includes(auth.userRole)) {
      return next('/')
    }
  }

  // DIOS only routes
  if (to.meta.diosOnly && auth.isLoggedIn) {
    if (auth.userRole !== 'DIOS') return next('/')
  }

  next()
})

export default router
