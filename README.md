# EigenLayer Petition with Supabase Integration

A pixel-art themed petition web application for the EigenLayer CT Intern position, integrated with Supabase for real-time data storage and management.

## Features

- 🎨 Retro pixel-art design with animations
- 🔥 Real-time signature updates
- 📊 Progress tracking (0/1000 signatures)
- 🚫 Duplicate signature prevention
- 📱 Mobile-responsive design
- ⚡ Supabase real-time subscriptions
- 🛡️ Built-in database constraints and security

## Database Features

- **Automatic duplicate checking**: Prevents the same handle from signing twice
- **1000 signature limit**: Database enforces maximum signature count
- **Real-time updates**: See new signatures as they come in
- **Secure storage**: Uses Supabase's built-in security features

## Setup Instructions

### 1. Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Get your project URL and API key from Settings > API
3. Run the SQL schema in your Supabase SQL editor:

```bash
# Copy the contents of petition_schema.sql and run it in Supabase SQL Editor
```

### 2. Environment Configuration

1. Copy the environment example file:
```bash
cp env.example .env
```

2. Update the `.env` file with your Supabase credentials:
```env
SUPABASE_URL=https://ueuswzvwuyammudtkrey.supabase.co
SUPABASE_ANON_KEY=your_actual_supabase_anon_key_here
```

### 3. Update the HTML File

In `index.html`, replace the placeholder API key:

```javascript
// Replace this line:
const SUPABASE_ANON_KEY = 'SUPABASE_ANON_KEY';

// With your actual API key:
const SUPABASE_ANON_KEY = 'your_actual_supabase_anon_key_here';
```

### 4. Install Dependencies (Optional)

If you want to use local development tools:

```bash
npm install
npm run dev  # Starts live-server for development
```

Or simply open `index.html` in your browser.

## Database Schema

The application uses a single table `petition_signatures` with the following structure:

```sql
petition_signatures (
    id SERIAL PRIMARY KEY,
    handle VARCHAR(255) NOT NULL UNIQUE,
    message TEXT DEFAULT '',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
```

### Key Database Features:

1. **Duplicate Prevention**: Triggers prevent duplicate handles (case-insensitive)
2. **Signature Limit**: Enforces maximum of 1000 signatures
3. **Optimized Queries**: Indexed for fast lookups and sorting
4. **Security**: Row Level Security (RLS) enabled with public read/insert policies

### Database Functions:

- `get_signature_count()`: Returns current signature count
- `add_signature(handle, message)`: Safely adds a signature with all validations
- `check_signature_limit()`: Trigger function to enforce 1000 signature limit
- `check_duplicate_signature()`: Trigger function to prevent duplicates

## Security Features

- **Row Level Security**: Enabled on the petition_signatures table
- **Input Validation**: Client-side and database-level validation
- **SQL Injection Protection**: Uses parameterized queries via Supabase
- **Rate Limiting**: Can be configured through Supabase dashboard

## File Structure

```
eigenlayer/
├── index.html                 # Main application file
├── petition_schema.sql        # Database schema and functions
├── supabase-client.js        # Supabase client configuration (for reference)
├── package.json              # Node.js dependencies
├── env.example               # Environment variables template
└── README.md                 # This file
```

## API Key Security

⚠️ **Important**: The API key is visible in the client-side code. This is the Supabase "anon" key which is designed to be public. However, make sure to:

1. Use the anon key (not the service role key)
2. Configure Row Level Security policies properly
3. Never expose your service role key in client-side code

## Real-time Features

The application automatically updates when new signatures are added through:

- Supabase real-time subscriptions
- Automatic UI refresh when database changes occur
- Live signature count updates

## Customization

You can customize:

- Colors and styling in the CSS section
- Maximum signature limit (change 1000 to your desired number)
- Validation rules in the database triggers
- Real-time update frequency

## Troubleshooting

### Common Issues:

1. **Signatures not saving**: Check your API key and Supabase URL
2. **Duplicate signatures allowed**: Ensure database triggers are properly installed
3. **Real-time updates not working**: Verify Supabase real-time is enabled in your project settings
4. **CORS errors**: Make sure your domain is added to Supabase allowed origins

### Database Issues:

Run this query to check your setup:

```sql
-- Check if table exists
SELECT * FROM petition_signatures LIMIT 1;

-- Check if triggers exist
SELECT * FROM information_schema.triggers WHERE trigger_name LIKE '%signature%';

-- Check signature count
SELECT get_signature_count();
```

## License

MIT License - feel free to use this code for your own projects!
