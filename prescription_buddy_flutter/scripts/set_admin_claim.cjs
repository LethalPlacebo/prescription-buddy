const admin = require('firebase-admin');

async function main() {
  const target = process.argv[2];
  const mode = (process.argv[3] || 'grant').toLowerCase();

  if (!target) {
    throw new Error(
      'Usage: node set_admin_claim.cjs <email-or-uid> [grant|revoke]',
    );
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });

  const auth = admin.auth();
  const userRecord = target.includes('@')
    ? await auth.getUserByEmail(target)
    : await auth.getUser(target);

  const isAdmin = mode != 'revoke';

  await auth.setCustomUserClaims(userRecord.uid, {admin: isAdmin});
  await auth.revokeRefreshTokens(userRecord.uid);

  const label = isAdmin ? 'granted' : 'revoked';
  console.log(`Admin access ${label} for ${userRecord.email || userRecord.uid}`);
  console.log('The user should sign out and back in to refresh the claim.');
}

main().catch((error) => {
  console.error(error.message || error);
  process.exitCode = 1;
});
