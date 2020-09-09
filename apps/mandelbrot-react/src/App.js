import React from 'react'
import ResizeablePanels from './components/ResizeablePanels'

import './App.css'
import Options from './components/Options'

function App() {
	return (
		<div className='App'>
			<ResizeablePanels>
				<div className='1'>
					<Options />
				</div>
				<div className='2'>Se4cond DIv</div>
			</ResizeablePanels>
		</div>
	)
}

export default App
