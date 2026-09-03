import React, { createContext, useContext, useEffect, useState } from 'react';
import { authApi } from '../api/endpoints';
import { AuthUser } from '../types';

interface AuthContextValue {
  user: AuthUser | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  register: (data: {
    email: string;
    password: string;
    name: string;
    phone?: string;
  }) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const stored = localStorage.getItem('vicoba_user');
    const token = localStorage.getItem('vicoba_token');
    if (stored && token) {
      setUser(JSON.parse(stored));
    }
    setLoading(false);
  }, []);

  function persistSession(accessToken: string, authUser: AuthUser) {
    localStorage.setItem('vicoba_token', accessToken);
    localStorage.setItem('vicoba_user', JSON.stringify(authUser));
    setUser(authUser);
  }

  async function login(email: string, password: string) {
    const { data } = await authApi.login(email, password);
    persistSession(data.accessToken, data.user);
  }

  async function register(payload: {
    email: string;
    password: string;
    name: string;
    phone?: string;
  }) {
    const { data } = await authApi.register(payload);
    persistSession(data.accessToken, data.user);
  }

  function logout() {
    localStorage.removeItem('vicoba_token');
    localStorage.removeItem('vicoba_user');
    localStorage.removeItem('vicoba_active_group');
    setUser(null);
  }

  return (
    <AuthContext.Provider value={{ user, loading, login, register, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
