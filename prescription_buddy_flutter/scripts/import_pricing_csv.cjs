const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const admin = require('firebase-admin');

const csvPath =
  process.argv[2] || 'C:\\Users\\Chris\\.codex\\updated_prescriptions.csv';
const mode = (process.argv[3] || 'append').toLowerCase();
const limitArg = process.argv[4];
const offsetArg = process.argv[5];
const limit =
  limitArg && limitArg.toLowerCase() !== 'all'
    ? Number.parseInt(limitArg, 10)
    : null;
const offset = Number.parseInt(offsetArg || '0', 10) || 0;

function parseCsvLine(line) {
  const values = [];
  let current = '';
  let inQuotes = false;

  for (let i = 0; i < line.length; i += 1) {
    const char = line[i];
    const nextChar = line[i + 1];

    if (char === '"') {
      if (inQuotes && nextChar === '"') {
        current += '"';
        i += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (char === ',' && !inQuotes) {
      values.push(current.trim());
      current = '';
      continue;
    }

    current += char;
  }

  values.push(current.trim());
  return values;
}

function titleCase(value) {
  return value
    .toLowerCase()
    .split(/[\s;/-]+/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function monthLabel(monthNumber) {
  const date = new Date(Date.UTC(2026, Number(monthNumber) - 1, 1));
  return date.toLocaleString('en-US', {month: 'long', timeZone: 'UTC'});
}

function buildMedicationName(row) {
  const ingredient = titleCase(row.Ingredient || '');
  const strength = (row.Strength || '').trim().toLowerCase();
  return [ingredient, strength].filter(Boolean).join(' ');
}

function normalizePrice(value) {
  const numeric = Number.parseFloat(value);
  if (!Number.isFinite(numeric)) {
    return '$0.00';
  }
  return `$${numeric.toFixed(2)}`;
}

function numericPrice(value) {
  const numeric = Number.parseFloat(value);
  return Number.isFinite(numeric) ? numeric : Number.POSITIVE_INFINITY;
}

function sourceLabel(row) {
  const pharmacy = row['Assigned Pharmacy'] || 'Imported pharmacy';
  return `Source: Imported CSV pricing for ${pharmacy}`;
}

function lastUpdatedLabel(row) {
  const year = row.Year || new Date().getFullYear();
  const month = row.Month ? monthLabel(row.Month) : 'Unknown month';
  return `Last updated ${month} ${year}`;
}

function createOffer(row) {
  const medicationName = buildMedicationName(row);
  const storeName = row['Assigned Pharmacy'] || 'Unknown pharmacy';
  const ndc = (row.NDC || '').trim();
  const idBase = `${medicationName}|${storeName}|${ndc}`;
  const id = crypto.createHash('md5').update(idBase).digest('hex');

  return {
    id,
    medicationName,
    genericName: titleCase(row.Ingredient || ''),
    storeName,
    priceLabel: normalizePrice(row['Estimated Price ($)']),
    sourceLabel: sourceLabel(row),
    lastUpdatedLabel: lastUpdatedLabel(row),
    isOtc: false,
    sourceType: 'csv_import',
    cmsPlanType: null,
    cmsContractId: null,
    cmsPlanId: null,
    searchName: medicationName.toLowerCase(),
    ndc,
    strength: (row.Strength || '').trim(),
    dosage: (row.Dosage || '').trim(),
    route: (row.Route || '').trim(),
    packageSize: (row['Package Size'] || '').trim(),
    productGroup: (row['Product Group'] || '').trim(),
    year: Number.parseInt(row.Year, 10) || null,
    month: Number.parseInt(row.Month, 10) || null,
    weightedAverageAmp: row['Weighted Average of AMPs'] || null,
    acaFul: row['ACA FUL'] || null,
    estimatedUnitPrice: row['Estimated Price ($)'] || null,
    aRated: row['A-Rated'] || null,
  };
}

function dedupeCheapestOffers(rows) {
  const cheapestByMedicationAndStore = new Map();

  for (const row of rows) {
    const medicationName = buildMedicationName(row).toLowerCase();
    const storeName = (row['Assigned Pharmacy'] || '').trim().toLowerCase();
    if (!medicationName || !storeName) {
      continue;
    }

    const key = `${medicationName}|${storeName}`;
    const currentPrice = numericPrice(row['Estimated Price ($)']);
    const existing = cheapestByMedicationAndStore.get(key);

    if (!existing) {
      cheapestByMedicationAndStore.set(key, row);
      continue;
    }

    const existingPrice = numericPrice(existing['Estimated Price ($)']);
    if (currentPrice < existingPrice) {
      cheapestByMedicationAndStore.set(key, row);
      continue;
    }

    if (
      currentPrice === existingPrice &&
      Number.parseFloat(row['Package Size'] || '0') >
          Number.parseFloat(existing['Package Size'] || '0')
    ) {
      cheapestByMedicationAndStore.set(key, row);
    }
  }

  return [...cheapestByMedicationAndStore.values()];
}

async function clearCollection(collectionRef) {
  const snapshot = await collectionRef.get();
  if (snapshot.empty) {
    return 0;
  }

  let deleted = 0;
  let batch = admin.firestore().batch();
  let count = 0;

  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
    deleted += 1;
    count += 1;

    if (count === 400) {
      await batch.commit();
      batch = admin.firestore().batch();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
  }

  return deleted;
}

async function main() {
  if (!fs.existsSync(csvPath)) {
    throw new Error(`CSV file not found: ${csvPath}`);
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });

  const csvText = fs.readFileSync(path.resolve(csvPath), 'utf8').trim();
  const lines = csvText.split(/\r?\n/).filter(Boolean);
  if (lines.length < 2) {
    throw new Error('CSV file does not contain any data rows.');
  }

  const headers = parseCsvLine(lines[0]);
  const allRows = lines.slice(1).map((line) => {
    const values = parseCsvLine(line);
    return Object.fromEntries(
      headers.map((header, index) => [header, values[index] || '']),
    );
  });

  const cheapestRows = dedupeCheapestOffers(allRows);
  cheapestRows.sort((a, b) => {
    const ingredientCompare = (a.Ingredient || '').localeCompare(
      b.Ingredient || '',
    );
    if (ingredientCompare != 0) {
      return ingredientCompare;
    }

    const priceCompare =
      numericPrice(a['Estimated Price ($)']) -
      numericPrice(b['Estimated Price ($)']);
    if (priceCompare != 0) {
      return priceCompare;
    }

    return (a['Assigned Pharmacy'] || '').localeCompare(
      b['Assigned Pharmacy'] || '',
    );
  });

  const slicedRows = cheapestRows.slice(
    offset,
    limit == null ? undefined : offset + limit,
  );

  const offers = slicedRows
    .map(createOffer)
    .filter((offer) => offer.medicationName && offer.storeName);

  const collection = admin.firestore().collection('pricing_offers');

  let deleted = 0;
  if (mode === 'replace') {
    deleted = await clearCollection(collection);
  }

  let batch = admin.firestore().batch();
  let count = 0;
  let committed = 0;

  for (const offer of offers) {
    batch.set(collection.doc(offer.id), offer);
    count += 1;

    if (count === 400) {
      await batch.commit();
      committed += count;
      console.log(
        `Committed ${committed}/${offers.length} offers (offset ${offset}).`,
      );
      batch = admin.firestore().batch();
      count = 0;
    }
  }

  if (count > 0) {
    await batch.commit();
    committed += count;
    console.log(
      `Committed ${committed}/${offers.length} offers (offset ${offset}).`,
    );
  }

  console.log(
    `Imported ${offers.length} pricing offers from ${csvPath} starting at row ${offset} after reducing ${allRows.length} source rows to ${cheapestRows.length} cheapest medication/store offers${
      mode === 'replace' ? ` after deleting ${deleted} existing offers` : ''
    }.`,
  );
}

main().catch((error) => {
  console.error(error.message || error);
  process.exitCode = 1;
});
