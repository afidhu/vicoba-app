import React, { createContext, useContext, useEffect, useState, useCallback } from 'react';
import { groupsApi } from '../api/endpoints';
import { Group, GroupMember, GroupRole } from '../types';
import { useAuth } from './AuthContext';

interface GroupContextValue {
  groups: Group[];
  activeGroup: Group | null;
  myMembership: GroupMember | null;
  loading: boolean;
  refreshGroups: () => Promise<void>;
  setActiveGroupId: (groupId: string) => void;
  hasRole: (...roles: GroupRole[]) => boolean;
}

const GroupContext = createContext<GroupContextValue | undefined>(undefined);

export function GroupProvider({ children }: { children: React.ReactNode }) {
  const { user } = useAuth();
  const [groups, setGroups] = useState<Group[]>([]);
  const [activeGroup, setActiveGroup] = useState<Group | null>(null);
  const [loading, setLoading] = useState(true);

  const refreshGroups = useCallback(async () => {
    if (!user) {
      setGroups([]);
      setActiveGroup(null);
      setLoading(false);
      return;
    }
    setLoading(true);
    try {
      const { data } = await groupsApi.list();
      setGroups(data);
      const storedId = localStorage.getItem('vicoba_active_group');
      const chosen = data.find((g) => g.id === storedId) || data[0] || null;
      if (chosen) {
        const { data: full } = await groupsApi.get(chosen.id);
        setActiveGroup(full);
        localStorage.setItem('vicoba_active_group', full.id);
      } else {
        setActiveGroup(null);
      }
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    refreshGroups();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [user]);

  async function setActiveGroupId(groupId: string) {
    localStorage.setItem('vicoba_active_group', groupId);
    const { data: full } = await groupsApi.get(groupId);
    setActiveGroup(full);
  }

  const myMembership =
    activeGroup?.members?.find((m) => m.userId === user?.id) || null;

  function hasRole(...roles: GroupRole[]) {
    if (!myMembership) return false;
    if (myMembership.role === 'OWNER') return true;
    return roles.includes(myMembership.role);
  }

  return (
    <GroupContext.Provider
      value={{ groups, activeGroup, myMembership, loading, refreshGroups, setActiveGroupId, hasRole }}
    >
      {children}
    </GroupContext.Provider>
  );
}

export function useGroup() {
  const ctx = useContext(GroupContext);
  if (!ctx) throw new Error('useGroup must be used within GroupProvider');
  return ctx;
}
