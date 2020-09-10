import React, { useState, Fragment } from 'react'
import Grid from '@material-ui/core/Grid'
import Radio from '@material-ui/core/Radio'
import Checkbox from '@material-ui/core/Checkbox'
import Slider from '@material-ui/core/Slider'
import RadioGroup from '@material-ui/core/RadioGroup'
import FormControlLabel from '@material-ui/core/FormControlLabel'

import OptionCard from './components/OptionCard'

import { rendererAr, threeDAr, themeAr, colorsAr } from './util'

import './styles/App.scss'

const App = () => {
	const [renderer, setRenderer] = useState('C++')
	const [threeD, setThreeD] = useState(threeDAr[0].label)
	const [theme, setTheme] = useState(themeAr[0].label)
	const [colors, setColors] = useState(colorsAr[0].label)
	// const [texture, setTexture] = useState()
	// const [adjustments, setAdjustments] = useState()
	// const [edge, setEdge] = useState()
	// const [motion, setMotion] = useState()

	const RadioForm = (title, state, setState, array) => (
		<div>
			<div className='title'>{title}</div>
			<RadioGroup
				aria-label={title.toLowerCase()}
				name={title.toLowerCase()}
				value={state}
				onChange={e => setState(e.target.value)}
			>
				{array.map(({ label }, index) => (
					<FormControlLabel
						key={index}
						value={label}
						control={<Radio />}
						label={label}
					/>
				))}
			</RadioGroup>
		</div>
	)

	return (
		<Fragment>
			<div>
				<Grid container alignItems='center'>
					<Grid item>
						<OptionCard>
							{RadioForm('Renderer', renderer, setRenderer, rendererAr)}
						</OptionCard>
					</Grid>

					<Grid item>
						<OptionCard>
							{RadioForm('3-D', threeD, setThreeD, threeDAr)}
						</OptionCard>
					</Grid>

					{renderer === 'C++' ? (
						<Grid item>
							<OptionCard>
								{RadioForm('Theme', theme, setTheme, themeAr)}
							</OptionCard>
						</Grid>
					) : (
						''
					)}

					{renderer !== 'Python' ? (
						<Grid item>
							<OptionCard>
								{RadioForm('Colors', colors, setColors, colorsAr)}
							</OptionCard>
						</Grid>
					) : (
						''
					)}
				</Grid>
			</div>
		</Fragment>
	)
}

export default App
