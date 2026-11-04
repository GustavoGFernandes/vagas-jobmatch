import Link from 'next/link';

export default function NaoEncontrada() {
  return (
    <div className="container pagina">
      <div className="estado cartao">
        <h2>Página não encontrada</h2>
        <Link href="/vagas" className="botao">Ver vagas</Link>
      </div>
    </div>
  );
}
