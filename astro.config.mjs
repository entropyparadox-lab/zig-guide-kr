import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
  site: 'https://entropyparadox-lab.github.io',
  base: '/zig-guide-kr',
  integrations: [
    starlight({
      title: 'Zig 한국어 가이드',
      description: 'Zig 공식 언어 레퍼런스(v0.16.0) 완역 및 실전 한국어 핸드북 & 가이드',
      logo: {
        alt: 'Zig KR Logo',
        src: './src/assets/zig-logo.svg',
        replacesTitle: false,
      },
      social: [
        {
          icon: 'github',
          label: 'GitHub',
          href: 'https://github.com/entropyparadox-lab/zig-guide-kr',
        },
      ],
      customCss: [
        './src/styles/custom.css',
      ],
      sidebar: [
        {
          label: '시작하기',
          items: [
            { label: '프로젝트 소개 및 안내', slug: 'intro' },
            { label: '개발자 표준 용어집 (Glossary)', slug: 'glossary' },
          ],
        },
        {
          label: '🚀 타 언어 사용자를 위한 Zig',
          badge: { text: 'New', variant: 'tip' },
          items: [
            { autogenerate: { directory: 'from-other-languages' } }
          ],
        },
        {
          label: '📖 Zig 실전 핸드북',
          items: [
            { autogenerate: { directory: 'guides' } }
          ],
        },
        {
          label: '📚 공식 언어 레퍼런스 (v0.16.0)',
          items: [
            { autogenerate: { directory: 'docs/0.16.0' } }
          ],
        },
        {
          label: '⚡ Master (Nightly / 0.17.0-dev)',
          badge: { text: 'Daily Sync', variant: 'note' },
          items: [
            { autogenerate: { directory: 'docs/master' } }
          ],
        },
      ],
    }),
  ],
});
