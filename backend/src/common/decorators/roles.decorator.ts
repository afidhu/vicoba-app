import { SetMetadata } from '@nestjs/common';

export const ROLES_KEY = 'roles';
/**
 * Restrict a route to specific group roles.
 * OWNER always has implicit access regardless of the roles listed here.
 * Usage: @Roles("ADMIN", "TREASURER")
 */
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);
