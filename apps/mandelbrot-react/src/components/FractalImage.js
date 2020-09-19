import React, { useEffect } from 'react'
import { useGesture } from 'react-use-gesture'

import store from '../store'

const FractalImage = ({ dimensions }) => {
	const { width: flexWidth, height: flexHeight } = dimensions
	const { pix_x, setSize, setXY, x, y, setPix, height } = store()

	const bind = useGesture({
		onDrag: ({ offset: [x, y] }) => setXY(-x / 200, -y / 200),
		onPinch: ({ offset: [d, _] }) => setPix(-d / 200),
		onWheel: ({ offset: [_, d] }) => setPix(d / 200),
	})

	useEffect(() => setSize(flexWidth, flexHeight), [flexWidth, flexHeight])

	console.log(x, y, pix_x)

	return (
		<div {...bind()} style={{ height }}>
			hey
		</div>
	)
}

export default FractalImage
