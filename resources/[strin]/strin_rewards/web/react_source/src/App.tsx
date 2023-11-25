import React, {useState} from 'react';
import {debugData} from "./utils/debugData";
import Wrapper from './components/Wrapper';
import Board from './components/Board';

// This will set the NUI to visible if we are
// developing in browser
debugData([
  {
    action: 'setVisible',
    data: true,
  }
])

const App: React.FC = () => {

  return (
    <Wrapper>
      <Board/>
    </Wrapper>
  );
}

export default App;
