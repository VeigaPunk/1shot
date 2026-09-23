#!/usr/bin/env node
// Operator-side. Seal magga/v2/envelope.md into a checkpoint's delivery/ENVELOPE.sealed.
//   node magga/v2/seal-envelope.mjs <checkpoint-dir> <prompt-raw-url>
// Writes the sealed box into the checkpoint and an operator record beside this script.
// The seal is a commitment device, not access control: the key is derivable from
// tooling/lock-submission.mjs. Early opening is detectable because the receipt code
// only exists inside the envelope; see the record's receipt_sha256.
import { createCipheriv, createHash, randomBytes, scryptSync } from 'node:crypto';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const [checkpoint, promptUrl] = process.argv.slice(2);
if (!checkpoint || !promptUrl) { console.error('usage: seal-envelope.mjs <checkpoint-dir> <prompt-raw-url>'); process.exit(1); }
const here = path.dirname(fileURLToPath(import.meta.url));
const sha256 = bytes => createHash('sha256').update(bytes).digest('hex');

const receipt = `MLNW-${randomBytes(6).toString('hex').toUpperCase()}`;
const plaintext = Buffer.from(readFileSync(path.join(here, 'envelope.md'), 'utf8')
  .replaceAll('{{RECEIPT}}', receipt).replaceAll('{{PROMPT_URL}}', promptUrl));
if (/\{\{[A-Z_]+\}\}/.test(plaintext.toString())) throw Error('unfilled placeholder in envelope');

const salt = randomBytes(16), iv = randomBytes(12);
const key = scryptSync('magga-v2 envelope: opened only after the submission is locked', salt, 32);
const cipher = createCipheriv('aes-256-gcm', key, iv);
const data = Buffer.concat([cipher.update(plaintext), cipher.final()]);
const box = {
  schema: 'magga-v2-envelope/1',
  note: 'Sealed publication instructions. tooling/lock-submission.mjs opens this after the submission is locked. Do not open it before.',
  salt: salt.toString('base64'), iv: iv.toString('base64'), tag: cipher.getAuthTag().toString('base64'),
  plaintext_sha256: sha256(plaintext), data: data.toString('base64'),
};
mkdirSync(path.join(checkpoint, 'delivery'), { recursive: true });
const sealedBytes = Buffer.from(JSON.stringify(box, null, 2) + '\n');
writeFileSync(path.join(checkpoint, 'delivery', 'ENVELOPE.sealed'), sealedBytes);
writeFileSync(path.join(here, 'envelope-record.json'), JSON.stringify({
  sealed_at: new Date().toISOString(), prompt_url: promptUrl,
  envelope_template_sha256: sha256(readFileSync(path.join(here, 'envelope.md'))),
  plaintext_sha256: box.plaintext_sha256, sealed_sha256: sha256(sealedBytes),
  receipt_sha256: sha256(receipt),
}, null, 2) + '\n');
console.log(`Sealed delivery/ENVELOPE.sealed (plaintext ${box.plaintext_sha256}); record written to magga/v2/envelope-record.json`);
