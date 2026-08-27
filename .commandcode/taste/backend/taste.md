# Taste Profile — Backend/Security

- Prefers user passwords to be stored and compared in plaintext — no hashing/encryption (explicitly asked "Password user nya jangan di enkripsi"; login compares raw values directly). Confidence: 0.9
- Prefers database user passwords to be a fixed, known value (e.g., `admin123`) rather than a randomly generated one, so login is predictable and documented (asked "jangan pakai password acak"). Confidence: 0.7
- Prefers server-side date-range filtering, aggregation, and pagination for report/list endpoints (instead of fetching all rows repeatedly) so large datasets stay fast. Confidence: 0.8
- Prefers role-based authorization enforced server-side: admin-only for user/account management (CRUD of kasir accounts, public register disabled) and for product create/update/delete; a `kasir` role gets read-only product access (needed for transactions) plus POS and reports; unauthorized roles should be rejected (e.g., 403). Confidence: 0.8
