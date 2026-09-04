import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * Reads the caller's membership in the :groupId route, attached by GroupRolesGuard.
 * Only usable on routes guarded by GroupRolesGuard.
 */
export const GroupMembership = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return request.groupMembership;
  },
);
