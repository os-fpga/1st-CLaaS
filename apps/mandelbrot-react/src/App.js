import React, { useState, Fragment } from 'react'
import Grid from '@material-ui/core/Grid'
import Radio from '@material-ui/core/Radio'
import Checkbox from '@material-ui/core/Checkbox'
import Slider from '@material-ui/core/Slider'
import FormGroup from '@material-ui/core/FormGroup'
import RadioGroup from '@material-ui/core/RadioGroup'
import FormControlLabel from '@material-ui/core/FormControlLabel'

import OptionCard from './components/OptionCard'

import {
	rendererAr,
	threeDAr,
	themeAr,
	colorsAr,
	edgeAr,
	motionAr,
} from './util'

import './styles/App.scss'

const App = () => {
	const [renderer, setRenderer] = useState('C++')
	const [threeD, setThreeD] = useState(threeDAr[0].label)
	const [theme, setTheme] = useState(themeAr[0].label)
	const [colors, setColors] = useState(colorsAr[0].label)
	const [texture, setTexture] = useState([])
	const [adjustments, setAdjustments] = useState({
		Depth: 30,
		Morph1: 30,
		Morph2: 30,
	})
	const [edge, setEdge] = useState(edgeAr[0].label)
	const [motion, setMotion] = useState(motionAr[0].label)

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

	// const CheckboxForm = (title, state, setState, array) => {
	// 	return (
	// 		<div>
	// 			<div className='title'>{title}</div>
	// 			<FormGroup>
	// 				<FormControlLabel
	// 					control={
	// 						<Checkbox
	// 							checked={state['Darken']}
	// 							onChange={e =>
	// 								setState({ ...state, [e.target.name]: e.target.checked })
	// 							}
	// 							name='Darken'
	// 						/>
	// 					}
	// 					label='Darken'
	// 				/>
	// 				{array.map({ label, checked, all } => {
	// 					renderer !== ''
	// 			})}
	// 			</FormGroup>
	// 		</div>
	// 	)
	// }

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

					{renderer === 'C++' ? (
						<Grid item>
							<OptionCard>
								{RadioForm('Edge', edge, setEdge, edgeAr)}
							</OptionCard>
						</Grid>
					) : (
						''
					)}

					<Grid item>
						<OptionCard>
							<div style={{ textAlign: 'center' }}>
								<div className='title'>Adjustments</div>
								<div className='legend'>Depth</div>
								<Slider
									value={adjustments.Depth}
									onChange={(_, val) =>
										setAdjustments({ ...adjustments, Depth: val })
									}
									className='slider'
									aria-labelledby='continuous-slider'
								/>
								{renderer === 'C++' ? (
									<>
										{' '}
										<div className='legend'>Morph 1</div>
										<Slider
											value={adjustments.Morph1}
											onChange={(_, val) =>
												setAdjustments({ ...adjustments, Morph1: val })
											}
											className='slider'
											aria-labelledby='continuous-slider'
										/>
										<div className='legend'>Morph 2</div>
										<Slider
											value={adjustments.Morph2}
											onChange={(_, val) =>
												setAdjustments({ ...adjustments, Morph2: val })
											}
											className='slider'
											aria-labelledby='continuous-slider'
										/>
									</>
								) : (
									''
								)}
							</div>
						</OptionCard>
					</Grid>

					<Grid item>
						<OptionCard>
							{RadioForm('Motion', motion, setMotion, motionAr)}
						</OptionCard>
					</Grid>
				</Grid>
			</div>
		</Fragment>
	)
}

export default App
