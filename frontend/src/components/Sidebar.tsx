import React from 'react';
import { NavLink } from 'react-router-dom';
import { useGroup } from '../context/GroupContext';

const links = [
  { to: '/dashboard', label: 'Dashboard', icon: 'bi-speedometer2' },
  { to: '/members', label: 'Members', icon: 'bi-people' },
  { to: '/contributions', label: 'Contributions', icon: 'bi-piggy-bank' },
  { to: '/shares', label: 'Shares', icon: 'bi-pie-chart' },
  { to: '/fines', label: 'Fines', icon: 'bi-exclamation-triangle' },
  { to: '/loans', label: 'Loans', icon: 'bi-cash-coin' },
  { to: '/expenses', label: 'Expenses', icon: 'bi-receipt' },
  { to: '/meetings', label: 'Meetings', icon: 'bi-calendar-event' },
  { to: '/transactions', label: 'Transactions', icon: 'bi-clock-history' },
  { to: '/reports', label: 'Reports', icon: 'bi-bar-chart' },
];

export default function Sidebar() {
  const { activeGroup } = useGroup();

  return (
    <div
      className="d-flex flex-column bg-success bg-gradient text-white p-3 vh-100"
      style={{ width: 240, position: 'sticky', top: 0 }}
    >
      <div className="mb-4">
        <h5 className="fw-bold mb-0">🤝 VICOBA</h5>
        <small className="text-white-50">{activeGroup?.name || 'No group selected'}</small>
      </div>
      <ul className="nav nav-pills flex-column gap-1">
        {links.map((link) => (
          <li className="nav-item" key={link.to}>
            <NavLink
              to={link.to}
              className={({ isActive }) =>
                'nav-link text-white d-flex align-items-center gap-2 ' +
                (isActive ? 'active bg-white bg-opacity-25 fw-semibold' : 'opacity-75')
              }
            >
              <i className={`bi ${link.icon}`} />
              {link.label}
            </NavLink>
          </li>
        ))}
      </ul>
      <div className="mt-auto">
        <NavLink to="/groups" className="nav-link text-white opacity-75 d-flex align-items-center gap-2">
          <i className="bi bi-arrow-left-right" />
          Switch group
        </NavLink>
      </div>
    </div>
  );
}
