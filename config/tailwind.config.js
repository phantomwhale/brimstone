const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
        western: ['Rye', 'cursive'],
        serif: ['Cinzel', 'serif'],
        body: ['"IM Fell English"', 'serif'],
      },
      colors: {
        parchment: {
          light: '#f4e4bc',
          DEFAULT: '#e8d4a8',
          dark: '#d4b896',
          border: '#8b7355',
        },
        wood: {
          light: '#8b6914',
          DEFAULT: '#5c4033',
          dark: '#3d2914',
        },
        leather: '#654321',
        gold: {
          DEFAULT: '#c9a227',
          light: '#d9b22a',
          dark: '#a88720',
        },
        health: {
          DEFAULT: '#a52a2a',
          dark: '#7a2020',
          border: '#5a1010',
        },
        sanity: {
          DEFAULT: '#2f4f4f',
          dark: '#1f3f3f',
          border: '#0f2f2f',
        },
        blood: '#8b0000',
        ink: '#1a1a1a',
      },
      boxShadow: {
        'inset-parchment': 'inset 0 0 30px rgba(139, 115, 85, 0.3)',
        'sheet': '0 10px 30px rgba(0, 0, 0, 0.3)',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/container-queries'),
  ]
}
