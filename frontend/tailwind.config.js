/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          blue: '#4A90E2',
          green: '#5CB85C',
          orange: '#F5A623',
        },
        neutral: {
          light: '#F8F9FA',
          card: '#E9ECEF',
          gray: '#6C757D',
        },
        text: {
          primary: '#2C3E50',
          secondary: '#495057',
        },
        status: {
          pending: '#F5A623',
          approved: '#5CB85C',
          inProgress: '#4A90E2',
          rejected: '#DC3545',
        },
        sidebar: '#2C3E50',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        heading: ['Poppins', 'Inter', 'sans-serif'],
      },
      borderRadius: {
        'card': '8px',
      },
      boxShadow: {
        'card': '0 2px 8px rgba(0,0,0,0.08)',
        'card-hover': '0 4px 12px rgba(0,0,0,0.12)',
      }
    },
  },
  plugins: [],
}
