import React from 'react'
import { ReflexContainer, ReflexSplitter, ReflexElement } from 'react-reflex'

import FractalImage from './components/FractalImage'
import Options from './components/Options'

const App = () => {
	return (
		<ReflexContainer style={{ height: '100vh' }} orientation='vertical'>
			<ReflexElement className='left-pane' minSize='300' renderOnResize>
				<Options />
			</ReflexElement>

			<ReflexSplitter />

			<ReflexElement
				className='right-pane'
				minSize='500'
				propagateDimensionsRate={200}
				propagateDimensions={true}
				flex={0.8}
			>
				<FractalImage />
			</ReflexElement>
		</ReflexContainer>
	)
}

export default App
