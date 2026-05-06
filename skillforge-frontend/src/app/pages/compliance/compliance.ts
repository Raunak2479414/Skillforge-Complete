import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { StatusBadgeComponent } from '../../shared/components/status-badge/status-badge';

@Component({
  selector: 'app-compliance',
  standalone: true,
  imports: [CommonModule, StatusBadgeComponent],
  templateUrl: './compliance.html',
})
export class ComplianceComponent {
  records = [
    { employee: 'I. Khan', cert: 'Secure Coding 101', status: 'Compliant', date: 'Jan 15' },
    { employee: 'A. Das', cert: 'First Aid Basics', status: 'Expiring', date: 'Feb 01' },
    { employee: 'T. Roy', cert: 'Azure Fundamentals', status: 'Enrolled', date: 'Feb 24' },
  ];

  auditLogs = [
    { user: 'Admin', action: 'Update Role', resource: 'User: A. Das', timestamp: 'Feb 20, 10:12' },
    { user: 'Trainer', action: 'Create Course', resource: 'Azure Fundamentals', timestamp: 'Feb 19, 14:47' },
    { user: 'HR', action: 'Run Compliance Check', resource: 'All Departments', timestamp: 'Feb 18, 09:30' },
  ];
}
