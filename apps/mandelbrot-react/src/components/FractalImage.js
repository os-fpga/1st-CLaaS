import React, { useEffect } from 'react'
import { useGesture } from 'react-use-gesture'
// import FractalMeet from './fractalMeet'

import store from '../store'

const FractalImage = ({ dimensions }) => {
	const { width: flexWidth, height: flexHeight } = dimensions
	const {
		height,
		width,
		renderer,
		three_d,
		theme,
		colors,
		darken,
		texture,
		x,
		y,
		brighten,
		edge,
		eye_adjust,
		eye_sep,
		max_depth,
		modes,
		offset_h,
		offset_w,
		pix_x,
		pix_y,
		test_flags,
		test_vars,
		var1,
		var2,
		setSize,
		setXY,
		setPix,
	} = store()

	const bind = useGesture({
		onDrag: ({ offset: [x, y] }) => setXY(-x / 200, -y / 200),
		onPinch: ({ offset: [d, _] }) => setPix(-d / 200),
		onWheel: ({ offset: [_, d] }) => setPix(d / 1000000),
	})

	useEffect(() => setSize(flexWidth, flexHeight), [flexWidth, flexHeight])

	return (
		<div {...bind()}>
			<img
				unselectable='on'
				draggable={false}
				style={{ cursor: 'grab', width: 200 }}
				src={`http://fractalvalley.net/img?json={%22x%22:${x},%22y%22:${y},%22pix_x%22:${pix_x},%22pix_y%22:${pix_x},%22width%22:256,%22height%22:256,%22max_depth%22:1225,%22test_flags%22:0,%22darken%22:true,%22brighten%22:0,%22modes%22:66,%22colors%22:2,%22texture%22:0,%22edge%22:0,%22var1%22:0,%22var2%22:0,%22renderer%22:%22cpp%22,%22theme%22:0,%22test_vars%22:[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],%22three_d%22:false,%22offset_w%22:0,%22offset_h%22:0,%22eye_sep%22:0,%22eye_adjust%22:0}`}
			/>
		</div>
	)
}

export default FractalImage
