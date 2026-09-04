import { ForbiddenException } from '@nestjs/common';

const PRIVILEGED_ROLES = ['OWNER', 'ADMIN', 'TREASURER', 'SECRETARY'];

interface Membership {
  id: string;
  role: string;
}

/**
 * A plain MEMBER may only ever query their own records: their membership id is
 * forced regardless of what (if anything) was requested. Privileged roles are
 * unrestricted and pass the requested filter through unchanged.
 */
export function scopeMemberId(membership: Membership, requestedMemberId?: string) {
  if (PRIVILEGED_ROLES.includes(membership.role)) return requestedMemberId;
  return membership.id;
}

/** Throws unless the record belongs to the caller or they hold a privileged role. */
export function assertOwnRecordOrPrivileged(membership: Membership, recordMemberId: string) {
  if (!PRIVILEGED_ROLES.includes(membership.role) && recordMemberId !== membership.id) {
    throw new ForbiddenException('You can only view your own records');
  }
}
