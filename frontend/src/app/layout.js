import './globals.css';
import { AuthProvider } from './_lib/AuthContext';
import Cabecalho from './_components/Cabecalho';

export const metadata = {
  title: 'JobMatch',
  description: 'Vagas, candidaturas e processo seletivo em um só lugar.',
};

export default function RootLayout({ children }) {
  return (
    <html lang="pt-BR">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        {/* eslint-disable-next-line @next/next/no-page-custom-font -- no App Router o layout vale para todas as páginas */}
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
      </head>
      <body>
        <AuthProvider>
          <Cabecalho />
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
