import React from 'react';
import { createRoot } from 'react-dom/client';
import SessionsNew from './pages/SessionsNew'
import TwitterSearchProcessesNew from './pages/TwitterSearchProcessesNew'
import TwitterSearchProcessesShow from './pages/TwitterSearchProcessesShow'

const renderComponent = (ComponentName, node) => {
  if (node == null) return

  const dataset = { ...node.dataset }
  const root = createRoot(node);
  root.render(<ComponentName dataset={dataset} />);
}

document.addEventListener('DOMContentLoaded', () => {
  renderComponent(SessionsNew, document.getElementById('sessions-new'))
  renderComponent(TwitterSearchProcessesNew, document.getElementById('twitter-search-processes-new'))
  renderComponent(TwitterSearchProcessesShow, document.getElementById('twitter-search-processes-show'))
})
