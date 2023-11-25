import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import App from './App';
import {VisibilityProvider} from "./providers/VisibilityProvider";
import csLocale from "dayjs/locale/cs";
import dayjs from 'dayjs';

dayjs.locale(csLocale);

ReactDOM.render(
  <React.StrictMode>
    <VisibilityProvider>
      <App />
    </VisibilityProvider>
  </React.StrictMode>,
  document.getElementById('root')
);
