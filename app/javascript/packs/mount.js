import React from 'react';
import { createRoot } from 'react-dom/client';
import HelloReact from './components/hello_react'

document.addEventListener('DOMContentLoaded', () => {
  const mountNode = document.getElementById('app');
  const message = mountNode.dataset.message;
  const root = createRoot(mountNode);
  root.render(<HelloReact message={ message } />);
})
