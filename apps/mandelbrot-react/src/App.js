import React from 'react'
import { ReflexContainer, ReflexSplitter, ReflexElement } from 'react-reflex'

import Options from './components/Options'

const App = () => {
	return (
		<ReflexContainer style={{ height: '100vh' }} orientation='vertical'>
			<ReflexElement className='left-pane' minSize='300'>
				<Options />
			</ReflexElement>

			<ReflexSplitter />

			<ReflexElement className='right-pane' minSize='500'>
				{/* <FractalImage /> */}
			</ReflexElement>
		</ReflexContainer>
	)
}

export default App
