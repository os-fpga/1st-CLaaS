import React from 'react'
import store from '../store'

import Renderer from './Renderer'
import ThreeD from './ThreeD'
import Theme from './Theme'

const Options = () => {
	const { tiled, renderer } = store()

	return (
		<div>
			<Renderer />
			{!tiled && <ThreeD />}
			{renderer === 'cpp' && <Theme />}
		</div>
	)
}

export default Options
