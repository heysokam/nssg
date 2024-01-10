/** @type {import('tailwindcss').Config} */
module.exports = {
  content: {
    relative : true, // Make content path relative to this file
    files    : ["../public/**/*.{html,js}"],
  },
  theme: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
