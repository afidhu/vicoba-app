import React from 'react';
import { Outlet, Navigate } from 'react-router-dom';
import Sidebar from './Sidebar';
import Navbar from './Navbar';
import { useGroup } from '../context/GroupContext';

export default function Layout() {
  const { activeGroup, loading } = useGroup();

  if (loading) {
    return (
      <div className="d-flex justify-content-center align-items-center vh-100">
        <div className="spinner-border text-success" role="status" />
      </div>
    );
  }

  if (!activeGroup) {
    return <Navigate to="/groups" replace />;
  }

  return (
    <div className="d-flex">
      <Sidebar />
      <div className="flex-grow-1" style={{ minWidth: 0 }}>
        <Navbar />
        <main className="p-4 bg-light" style={{ minHeight: 'calc(100vh - 73px)' }}>
          <Outlet />
        </main>
      </div>
    </div>
  );
}
