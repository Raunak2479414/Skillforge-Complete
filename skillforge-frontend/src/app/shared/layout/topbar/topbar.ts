import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { AuthService } from '../../../core/services/auth.service';
import { ThemeService } from '../../../core/services/theme.service';

@Component({
  selector: 'app-topbar',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './topbar.html',
})
export class TopbarComponent {
  private auth = inject(AuthService);
  readonly theme = inject(ThemeService);
  readonly user = this.auth.user;

  logout() { this.auth.logout(); }
  toggleTheme() { this.theme.toggle(); }
}
