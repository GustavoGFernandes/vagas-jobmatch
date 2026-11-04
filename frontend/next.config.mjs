/** @type {import('next').NextConfig} */
const nextConfig = {
  // Gera uma versão enxuta para rodar no Docker (veja o Dockerfile)
  output: 'standalone',
};

export default nextConfig;
