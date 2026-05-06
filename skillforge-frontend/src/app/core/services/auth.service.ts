import { Injectable, signal, computed } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap, catchError, throwError } from 'rxjs';
import { environment } from '../../../environments/environment';
import { AuthTokens, JwtPayload, LoginRequest, RegisterRequest, UserRole } from '../models';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly TOKEN_KEY = 'sf_access_token';
  private readonly REFRESH_KEY = 'sf_refresh_token';

  private _user = signal<JwtPayload | null>(this.loadUserFromToken());
  readonly user = this._user.asReadonly();
  readonly isLoggedIn = computed(() => !!this._user());
  readonly userRole = computed(() => this._user()?.role ?? null);
  readonly userName = computed(() => this._user()?.name ?? '');
  readonly userId = computed(() => this._user()?.id ? Number(this._user()!.id) : null);

  constructor(private http: HttpClient, private router: Router) {}

  login(request: LoginRequest) {
    return this.http.post<AuthTokens>(`${environment.apiUrl}/Auth/login`, request).pipe(
      tap(tokens => this.handleTokens(tokens)),
      catchError(err => throwError(() => err))
    );
  }

  register(request: RegisterRequest) {
    return this.http.post<{ message: string }>(`${environment.apiUrl}/User/Register`, request).pipe(
      catchError(err => throwError(() => err))
    );
  }

  logout() {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_KEY);
    this._user.set(null);
    this.router.navigate(['/login']);
  }

  getToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  hasRole(...roles: UserRole[]): boolean {
    const role = this.userRole();
    return role ? roles.includes(role) : false;
  }

  private handleTokens(tokens: AuthTokens) {
    localStorage.setItem(this.TOKEN_KEY, tokens.access_token);
    localStorage.setItem(this.REFRESH_KEY, tokens.refresh_token);
    const payload = this.decodeJwt(tokens.access_token);
    this._user.set(payload);
  }

  private loadUserFromToken(): JwtPayload | null {
    const token = localStorage.getItem(this.TOKEN_KEY);
    if (!token) return null;
    try {
      const payload = this.decodeJwt(token);
      if (payload && payload.exp * 1000 > Date.now()) return payload;
      localStorage.removeItem(this.TOKEN_KEY);
      return null;
    } catch {
      return null;
    }
  }

  private decodeJwt(token: string): JwtPayload {
    const base64 = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/');
    const json = decodeURIComponent(
      atob(base64).split('').map(c => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2)).join('')
    );
    return JSON.parse(json);
  }
}
