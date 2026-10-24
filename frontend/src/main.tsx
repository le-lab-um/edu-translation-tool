import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
import './styles.css';

const root = document.getElementById('root');

if (!root) {
  throw new Error('Não foi encontrado o elemento de montagem da aplicação.');
}

createRoot(root).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
