import React, { useState } from 'react'
import Grid from '@material-ui/core/Grid'
import { withStyles, makeStyles } from '@material-ui/core/styles'
import Radio from '@material-ui/core/Radio'
import Checkbox from '@material-ui/core/Checkbox'
import Slider from '@material-ui/core/Slider'
import OptionCard from './OptionCard'

const PrettoSlider = withStyles({
	root: {
		color: '#52af77',
		height: 8,
	},
	thumb: {
		height: 24,
		width: 24,
		backgroundColor: '#fff',
		border: '2px solid currentColor',
		marginTop: -8,
		marginLeft: -12,
		'&:focus, &:hover, &$active': {
			boxShadow: 'inherit',
		},
	},
	active: {},
	valueLabel: {
		left: 'calc(-50% + 4px)',
	},
	track: {
		height: 8,
		borderRadius: 4,
	},
	rail: {
		height: 8,
		borderRadius: 4,
	},
})(Slider)

const rendererAr = [
	{
		label: 'Python',
	},
	{
		label: 'C++',
	},
	{
		label: 'FPGA/opt',
	},
]

const Options = () => {
	const [renderer, setRenderer] = useState(1)
	const [threeD, setThreeD] = useState()
	const [theme, setTheme] = useState()
	const [texture, setTexture] = useState()
	const [adjustments, setAdjustments] = useState()
	const [edge, setEdge] = useState()
	const [motion, setMotion] = useState()
	return (
		<div>
			<OptionCard title='Renderer'>
				{rendererAr.map(({ label }, index) => (
					<Grid container alignItems='center' justify='center' spacing={2}>
						<Grid item xs={2}>
							<Checkbox
								checked={renderer === index}
								onChange={() => setRenderer(index)}
							/>
						</Grid>
						<Grid item xs={10}>
							{label}
						</Grid>
					</Grid>
				))}
			</OptionCard>
		</div>
	)
}

export default Options
