import React from 'react'
import store from '../store'

import Renderer from './Renderer'
import ThreeD from './ThreeD'
import Theme from './Theme'
import Colors from './Colors'
import Texture from './Texture'

const Options = () => {
	const { tiled, renderer } = store()

	return (
		<div>
			<Renderer />
			{!tiled && <ThreeD />}
			{renderer === 'cpp' && <Theme />}
			{renderer !== 'python' && <Colors />}
			<Texture />
		</div>
	)
}

export default Options
