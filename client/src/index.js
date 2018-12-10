import React from 'react';
import ReactDOM from 'react-dom';
import Layout from './ActionBlocks/Layout/Layout.js';
import AuthenticationProvider from './Devise/AuthenticationProvider.js';
import BlockProvider from './ActionBlocks/BlockProvider.js';

ReactDOM.render(
  <AuthenticationProvider>
    <BlockProvider>
      <Layout block_key='layout-main' />
    </BlockProvider>
  </AuthenticationProvider>
  , document.getElementById('root'));
