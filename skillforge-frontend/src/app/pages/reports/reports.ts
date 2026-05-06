import { Component, inject, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ReportService, ReportSchedule } from '../../core/services/report.service';
import { SpinnerComponent } from '../../shared/components/spinner/spinner';

@Component({
  selector: 'app-reports',
  standalone: true,
  imports: [CommonModule, FormsModule, SpinnerComponent],
  templateUrl: './reports.html',
})
export class ReportsComponent implements OnInit {
  private reportSvc = inject(ReportService);

  scope = signal('Course');
  toast = signal('');
  toastType = signal<'success' | 'error' | 'info'>('info');

  schedules = signal<ReportSchedule[]>([]);
  schedulesLoading = signal(true);
  schedulesError = signal('');

  generating = signal(false);
  deactivatingId = signal<number | null>(null);

  bars = [
    { label: 'Completion Rate', heights: [50, 65, 85, 70, 90] },
    { label: 'Compliance',      heights: [80, 60, 70, 75, 85] },
    { label: 'Gap Closure',     heights: [40, 55, 65, 75, 80] },
  ];

  ngOnInit() {
    this.loadSchedules();
  }

  loadSchedules() {
    this.schedulesLoading.set(true);
    this.schedulesError.set('');
    this.reportSvc.getSchedules().subscribe({
      next: data => { this.schedules.set(data); this.schedulesLoading.set(false); },
      error: err => {
        this.schedulesError.set(err?.error?.message ?? 'Failed to load schedules.');
        this.schedulesLoading.set(false);
      }
    });
  }

  deactivate(id: number) {
    if (!confirm('Deactivate this schedule? No further reports will be auto-generated from it.')) return;
    this.deactivatingId.set(id);
    this.reportSvc.deactivateSchedule(id).subscribe({
      next: res => {
        this.schedules.update(list =>
          list.map(s => s.scheduleID === id ? { ...s, isActive: false } : s)
        );
        this.showToast(res.message, 'success');
        this.deactivatingId.set(null);
      },
      error: err => {
        this.showToast(err?.error?.message ?? 'Failed to deactivate schedule.', 'error');
        this.deactivatingId.set(null);
      }
    });
  }

  generate() {
    this.generating.set(true);
    this.reportSvc.generateReport(this.scope()).subscribe({
      next: (blob: any) => {
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `SkillForge-Report-${this.scope()}-${new Date().toISOString().slice(0,10)}.pdf`;
        a.click();
        URL.revokeObjectURL(url);
        this.showToast('Report generated and downloaded.', 'success');
        this.generating.set(false);
      },
      error: err => {
        this.showToast(err?.error?.message ?? 'Report generation failed.', 'error');
        this.generating.set(false);
      }
    });
  }

  get activeCount()   { return this.schedules().filter(s => s.isActive).length; }
  get inactiveCount() { return this.schedules().filter(s => !s.isActive).length; }

  private showToast(msg: string, type: 'success' | 'error' | 'info') {
    this.toast.set(msg);
    this.toastType.set(type);
    setTimeout(() => this.toast.set(''), 4000);
  }
}
