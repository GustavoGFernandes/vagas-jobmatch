'use client';

import { Suspense, useState } from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAuth } from '@/app/_lib/AuthContext';
import { Aviso } from '@/app/_components/Estados';

// Contas criadas pelo "npm run db:seed" no backend, para testar rápido
const CONTAS_TESTE = [
  { rotulo: 'Candidata (Ana)', email: 'ana@jobmatch.dev' },
  { rotulo: 'Recrutadora (Rita, Acme)', email: 'rita@acme.dev' },
];

export default function PaginaLogin() {
  return <Suspense><Login /></Suspense>;
}

function Login() {
  const { entrar } = useAuth();
  const router = useRouter();
  const voltar = useSearchParams().get('voltar');
  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');
  const [erro, setErro] = useState('');
  const [enviando, setEnviando] = useState(false);

  async function enviar(e) {
    e.preventDefault();
    setErro('');
    setEnviando(true);
    try {
      const usuario = await entrar(email, senha);
      // só aceita caminhos internos em ?voltar=
      const destino = voltar && voltar.startsWith('/') && !voltar.startsWith('//') ? voltar : null;
      router.replace(destino || (usuario.perfil === 'RECRUTADOR' ? '/empresa/vagas' : '/vagas'));
    } catch (err) {
      setErro(err.message);
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="login">
      <section className="lado">
        <Link href="/vagas" className="marca" style={{ color: '#fff' }}>JobMatch</Link>
        <h1>Sua próxima vaga começa aqui</h1>
        <p>Candidatos acompanham cada etapa. Empresas organizam o processo seletivo do início ao fim.</p>
      </section>
      <section className="form-lado">
        <form className="cartao pilha" onSubmit={enviar} noValidate>
          <h2>Entrar na sua conta</h2>
          <Aviso>{erro}</Aviso>
          <label className="campo">E-mail
            <input type="email" autoComplete="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
          </label>
          <label className="campo">Senha
            <input type="password" autoComplete="current-password" required value={senha} onChange={(e) => setSenha(e.target.value)} />
          </label>
          <button type="submit" className="botao" disabled={enviando || !email || !senha}>
            {enviando ? 'Entrando…' : 'Entrar'}
          </button>
          <div className="contas-teste texto-2">
            Contas de teste (senha <strong>Senha123</strong>):<br />
            {CONTAS_TESTE.map((c) => (
              <button key={c.email} type="button" className="botao neutro pequeno"
                onClick={() => { setEmail(c.email); setSenha('Senha123'); }}>{c.rotulo}</button>
            ))}
          </div>
          <Link href="/vagas" className="pequeno">Ver vagas sem entrar</Link>
        </form>
      </section>
    </div>
  );
}
