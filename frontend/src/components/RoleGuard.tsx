import React from 'react';
import { GroupRole } from '../types';
import { useGroup } from '../context/GroupContext';

export default function RoleGuard({
  roles,
  children,
  fallback = null,
}: {
  roles: GroupRole[];
  children: React.ReactNode;
  fallback?: React.ReactNode;
}) {
  const { hasRole } = useGroup();
  if (!hasRole(...roles)) return <>{fallback}</>;
  return <>{children}</>;
}
