import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { AuthService } from '../../core/services/auth.service';
import { StatusBadgeComponent } from '../../shared/components/status-badge/status-badge';

@Component({
  selector: 'app-enrollment',
  standalone: true,
  imports: [CommonModule, FormsModule, StatusBadgeComponent],
  templateUrl: './enrollment.html',
})
export class EnrollmentComponent {
  readonly auth = inject(AuthService);
  readonly role = this.auth.userRole;
  statusFilter = signal('All');

  enrollments = [
    { employee: 'I. Khan', course: 'Secure Coding 101', date: 'Feb 22', status: 'Enrolled', attendance: 'Present' },
    { employee: 'A. Das', course: 'First Aid Basics', date: 'Feb 23', status: 'Enrolled', attendance: 'Absent' },
    { employee: 'T. Roy', course: 'Azure Fundamentals', date: 'Feb 24', status: 'Waitlist', attendance: '—' },
  ];

  get filtered() {
    const f = this.statusFilter();
    return f === 'All' ? this.enrollments : this.enrollments.filter(e => e.status === f);
  }

  get canAssign() { return this.auth.hasRole('Manager', 'Admin'); }
}
