// Merges tool/l10n/*.json fragments ({ key: [ar, en, "placeholder:Type,..."?] })
// into lib/core/l10n/arb/app_ar.arb (template) and app_en.arb.
// Usage: node tool/merge_arb.js && flutter gen-l10n
const fs = require('fs');
const path = require('path');

const fragmentsDir = path.join(__dirname, 'l10n');
const outDir = path.join(__dirname, '..', 'lib', 'core', 'l10n', 'arb');
fs.mkdirSync(outDir, { recursive: true });

const ar = { '@@locale': 'ar' };
const en = { '@@locale': 'en' };
const seen = new Set();

for (const file of fs.readdirSync(fragmentsDir).filter((f) => f.endsWith('.json')).sort()) {
  const fragment = JSON.parse(fs.readFileSync(path.join(fragmentsDir, file), 'utf8'));
  for (const [key, value] of Object.entries(fragment)) {
    if (seen.has(key)) throw new Error(`Duplicate key ${key} in ${file}`);
    seen.add(key);
    const [arText, enText, spec] = value;
    if (typeof arText !== 'string' || typeof enText !== 'string') {
      throw new Error(`Key ${key} needs [ar, en]`);
    }
    ar[key] = arText;
    en[key] = enText;
    if (spec) {
      const placeholders = {};
      for (const part of spec.split(',')) {
        const [name, type] = part.split(':');
        placeholders[name.trim()] = { type: type.trim() };
      }
      ar[`@${key}`] = { placeholders };
    }
  }
}

fs.writeFileSync(path.join(outDir, 'app_ar.arb'), JSON.stringify(ar, null, 2) + '\n');
fs.writeFileSync(path.join(outDir, 'app_en.arb'), JSON.stringify(en, null, 2) + '\n');
console.log(`Merged ${seen.size} keys`);
