import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { GroupProvider } from './context/GroupContext';
import PrivateRoute from './components/PrivateRoute';
import Layout from './components/Layout';

import Login from './pages/Login';
import Register from './pages/Register';
import GroupSetup from './pages/GroupSetup';
import Dashboard from './pages/Dashboard';
import Members from './pages/Members';
import Contributions from './pages/Contributions';
import Shares from './pages/Shares';
import Fines from './pages/Fines';
import Loans from './pages/Loans';
import Expenses from './pages/Expenses';
import Meetings from './pages/Meetings';
import Transactions from './pages/Transactions';
import Reports from './pages/Reports';

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <GroupProvider>
          <Routes>
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route
              path="/groups"
              element={
                <PrivateRoute>
                  <GroupSetup />
                </PrivateRoute>
              }
            />
            <Route
              element={
                <PrivateRoute>
                  <Layout />
                </PrivateRoute>
              }
            >
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/members" element={<Members />} />
              <Route path="/contributions" element={<Contributions />} />
              <Route path="/shares" element={<Shares />} />
              <Route path="/fines" element={<Fines />} />
              <Route path="/loans" element={<Loans />} />
              <Route path="/expenses" element={<Expenses />} />
              <Route path="/meetings" element={<Meetings />} />
              <Route path="/transactions" element={<Transactions />} />
              <Route path="/reports" element={<Reports />} />
            </Route>
            <Route path="*" element={<Navigate to="/dashboard" replace />} />
          </Routes>
        </GroupProvider>
      </AuthProvider>
    </BrowserRouter>
  );
}
