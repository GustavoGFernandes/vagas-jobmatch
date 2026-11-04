import { redirect } from 'next/navigation';

// A página inicial leva direto para a lista de vagas
export default function Inicio() {
  redirect('/vagas');
}
