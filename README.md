# Barzanges Nye Hjemmeside 🚗🛢️

Vehicle-to-oil lookup system bygget med **Lovable AI** og **CarAPI**.

Brugeren finder den rigtige motorolie til sin bil ved at indtaste nummerplade eller vælge manuelt.

---

## Arkitektur

```
Bruger → Lovable Frontend → Lovable Backend → CarAPI (bil-identifikation)
                                            → Lovable Cloud DB (olie-anbefaling)
```

**CarAPI** finder bilen. **Lovable Cloud database** finder olien.

---

## Kom i gang

### 1. Opret CarAPI konto

Gå til [carapi.app](https://carapi.app) og opret en konto.
Du skal bruge **begge**: `api_token` og `api_secret`.

### 2. Tilføj secrets i Lovable

Inde i Lovable → **Settings → Environment Variables**, tilføj:

```
CARAPI_TOKEN=din_token_her
CARAPI_SECRET=dit_secret_her
```

> ⚠️ Disse nøgler må ALDRIG ligge i frontend-koden eller commites til GitHub.

### 3. Importér dette repo i Lovable

1. Gå til [lovable.dev](https://lovable.dev)
2. Opret nyt projekt → "Import from GitHub"
3. Vælg dette repo: `cimr205/barzanges-nye-hjemmeside`
4. Sæt environment variables ind (trin 2)
5. Brug Lovable-prompten nedenfor

---

## Lovable Master Prompt

Kopiér denne prompt direkte ind i Lovable chat:

```
Byg en produktionsklar vehicle-to-oil lookup funktion i vores app.

Vi bruger CarAPI som vehicle data provider.
Vi bruger Lovable Cloud som database — IKKE Supabase.
CarAPI må aldrig kaldes direkte fra browseren.
Alle CarAPI-kald skal gå gennem server-side funktioner i Lovable.

Mål:
Brugeren skal kunne indtaste nummerplade eller vælge bil manuelt.
Systemet skal identificere bilens year, make, model og trim via CarAPI.
Når bilen er identificeret, skal systemet finde den rigtige olie fra vores egen Lovable Cloud database.

Vigtige krav:
- Brug Lovable Cloud database til alle datatabeller
- Brug secure environment variables til CARAPI_TOKEN og CARAPI_SECRET
- Implementer login mod CarAPI auth endpoint: POST /api/auth/login
- Gem JWT midlertidigt og genbrug det indtil udløb
- Byg server-side API routes i Lovable til years, makes, models, trims og oil lookup
- Byg en olie-matcher som bruger vores egen Lovable Cloud tabel til endelig anbefaling
- Hvis nummerplade-opslag ikke er nok, skal der være manuel fallback
- Returner altid normaliseret vehicle data til frontend

Byg følgende:

1. Frontend:
- nummerplade input felt
- manuel vehicle selector (year → make → model → trim)
- recommendation card med olie, viskositet og specifikation

2. Backend services (Lovable server functions):
- carapi-auth: logger ind og gemmer JWT
- carapi-client: kalder CarAPI endpoints
- vehicle-resolver: normaliserer bildata
- oil-matcher: matcher bil til olieprodukter via Lovable Cloud DB

3. Lovable Cloud database-tabeller:
- oil_products (id, name, sku, viscosity, specification, description)
- vehicle_oil_map (id, make, model, year_from, year_to, trim_keyword, engine_keyword, oil_product_sku, priority)
- vehicle_search_logs (id, input, resolved_vehicle, recommended_oil, created_at)

4. API routes:
- /api/vehicle/years
- /api/vehicle/makes
- /api/vehicle/models
- /api/vehicle/trims
- /api/oil/recommend

Frontend flow:
1. bruger skriver nummerplade eller vælger manuelt
2. backend identificerer bilen via CarAPI
3. hvis flere trims findes, skal brugeren vælge
4. backend matcher bilen til vores olieprodukter i Lovable Cloud DB
5. frontend viser anbefalet olie og alternativer

Lav først backend og database. Lav derefter frontend.
Koden skal være modulær og klar til produktion.
```

---

## Database struktur (Lovable Cloud)

### oil_products
| Kolonne | Type | Beskrivelse |
|---|---|---|
| id | uuid | Primær nøgle |
| name | text | Produktnavn |
| sku | text | Varenummer |
| viscosity | text | fx "5W-30" |
| specification | text | fx "VW 504.00" |
| description | text | Kort beskrivelse |

### vehicle_oil_map
| Kolonne | Type | Beskrivelse |
|---|---|---|
| id | uuid | Primær nøgle |
| make | text | fx "BMW" |
| model | text | fx "320d" |
| year_from | int | fx 2019 |
| year_to | int | fx 2023 |
| trim_keyword | text | fx "2.0 TDI" |
| engine_keyword | text | fx "diesel" |
| oil_product_sku | text | Reference til oil_products |
| priority | int | Højere = mere specifik match |

### vehicle_search_logs
| Kolonne | Type | Beskrivelse |
|---|---|---|
| id | uuid | Primær nøgle |
| input | text | Hvad brugeren søgte |
| resolved_vehicle | json | Normaliseret bildata |
| recommended_oil | text | SKU på anbefalet olie |
| created_at | timestamp | Tidsstempel |

---

## CarAPI flow

```
1. POST /api/auth/login
   Body: { api_token, api_secret }
   Svar: JWT token

2. GET /api/years
   Header: Authorization: Bearer <JWT>

3. GET /api/makes?year=2021
   Header: Authorization: Bearer <JWT>

4. GET /api/models?year=2021&make=BMW
   Header: Authorization: Bearer <JWT>

5. GET /api/trims?year=2021&make=BMW&model=3+Series
   Header: Authorization: Bearer <JWT>
```

---

## Versionsplan

| Version | Indhold |
|---|---|
| v1 | Manuel valg + CarAPI + oliematch fra Lovable Cloud DB |
| v2 | Dansk nummerplade-opslag (DMR API) |
| v3 | Adminpanel til oliemapping + søgestatistik |

---

## Sikkerhed

- API-nøgler ligger **kun** som Lovable environment variables
- CarAPI kaldes **aldrig** direkte fra browseren
- .env filer commites **ikke** til GitHub

---

## Teknologi

- **Frontend + Backend + Database**: Lovable (Lovable Cloud)
- **Bil-data**: CarAPI (https://carapi.app)
- **Hosting**: Lovable (automatisk)
