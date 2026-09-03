import React from 'react';
import { useAuth } from '../context/AuthContext';
import { useGroup } from '../context/GroupContext';
import { useNavigate } from 'react-router-dom';

export default function Navbar() {
  const { user, logout } = useAuth();
  const { myMembership } = useGroup();
  const navigate = useNavigate();

  return (
    <nav className="navbar navbar-light bg-white border-bottom px-4 py-3">
      <span className="fw-semibold text-secondary">
        {myMembership ? `Signed in as ${myMembership.role.toLowerCase()}` : ''}
      </span>
      <div className="d-flex align-items-center gap-3">
        <span className="text-dark">{user?.name}</span>
        <button
          className="btn btn-outline-secondary btn-sm"
          onClick={() => {
            logout();
            navigate('/login');
          }}
        >
          Logout
        </button>
      </div>
    </nav>
  );
}
