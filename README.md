# Restaurant QR Menu & Admin Dashboard

A complete, production-ready QR menu management system for a small Turkish home-cooking restaurant. Customers scan a QR code with their phone camera and browse a beautiful digital menu — no app installation required. Restaurant owners manage everything via a private admin dashboard.

## Features

- **Public Menu** — Beautiful, mobile-first menu with categories, product cards, photos, prices in TL
- **Admin Dashboard** — Protected area with product, category, and restaurant management
- **Product Management** — Add, edit, delete products; image upload; availability toggle; search & filter
- **Category Management** — Create, rename, reorder, and delete categories with safety checks
- **Restaurant Settings** — Logo, name, description, phone, address, opening hours, social media
- **QR Code Generation** — Generate QR code, download as PNG or SVG, print A4 layout (4 copies)
- **Authentication** — Supabase Auth with password reset, session persistence, route guards
- **Security** — Row Level Security on all tables; public users cannot modify data
- **Fully Turkish** — All UI labels, messages, validation, and price formatting in Turkish

## Technology Stack

| Layer | Technology |
|---|---|
| Framework | Vue 3 (Composition API) |
| Build tool | Vite |
| Styling | Tailwind CSS v4 |
| Icons | @lucide/vue |
| State | Pinia |
| Routing | Vue Router 4 |
| Database | Supabase PostgreSQL |
| Auth | Supabase Authentication |
| Storage | Supabase Storage |
| QR Code | qrcode npm library |
| Deployment | Netlify |

## Project Structure

```
src/
├── components/
│   ├── admin/
│   │   └── ProductFormModal.vue
│   ├── menu/
│   │   ├── CategoryNav.vue
│   │   ├── ProductCard.vue
│   │   └── RestaurantHeader.vue
│   └── ui/
│       ├── ConfirmDialog.vue
│       ├── ImageUploader.vue
│       └── ToastContainer.vue
├── layouts/
│   └── AdminLayout.vue
├── lib/
│   ├── formatters.js
│   ├── imageHelpers.js
│   └── supabase.js
├── router/
│   └── index.js
├── stores/
│   ├── auth.js
│   └── toast.js
├── views/
│   ├── admin/
│   │   ├── CategoriesView.vue
│   │   ├── DashboardView.vue
│   │   ├── ProductsView.vue
│   │   ├── QRView.vue
│   │   └── SettingsView.vue
│   ├── LoginView.vue
│   └── MenuView.vue
├── App.vue
├── main.js
└── style.css
supabase/
└── migrations/
    ├── 001_schema.sql
    ├── 002_rls.sql
    └── 004_seed.sql
```

## Local Development

### Prerequisites
- Node.js 18+
- A Supabase project (free tier works)

### Setup

1. **Clone or open the project**
   ```bash
   cd "Alsancak Pilav Fakültesi"
   ```

2. **Install dependencies** (already done if you've run this once)
   ```bash
   npm install
   ```

3. **Create your .env file**
   ```bash
   copy .env.example .env
   ```
   Then fill in your Supabase URL and anon key.

4. **Run the database migrations** in Supabase SQL Editor (see `SETUP_GUIDE_TR.md`)

5. **Start development server**
   ```bash
   npm run dev
   ```

6. Open `http://localhost:5173/menu` for the public menu  
   Open `http://localhost:5173/admin` for the admin dashboard  
   Open `http://localhost:5173/login` to log in

## Commands

| Command | Description |
|---|---|
| `npm run dev` | Start development server |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build locally |

## Deployment

See `SETUP_GUIDE_TR.md` for complete Turkish deployment instructions.

Quick summary:
1. Push to GitHub
2. Connect repo to Netlify
3. Set environment variables in Netlify dashboard
4. Set `VITE_PUBLIC_MENU_URL` to your Netlify domain + `/menu`
5. Deploy

## Security

See `SECURITY.md` for a full explanation of authentication, RLS, and secret management.
