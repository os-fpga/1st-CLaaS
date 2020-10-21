import React from 'react'
import OptionCard from './OptionCard'
import store from '../store'

const colors_array = [
	{
		value: 0,
		label: 'Gradual Gradient',
	},
	{
		value: 1,
		label: 'Random',
	},
	{
		value: 2,
		label: 'Medium Gradient',
	},
	{
		value: 3,
		label: 'Rainbow',
	},
]

const Colors = () => {
	const { colors, setColors } = store()

	return (
		<OptionCard>
			<div className='title'>Colors</div>

			<form>
				{colors_array.map(({ label, value }, idx) => (
					<div key={idx}>
						<label>
							<input
								type='radio'
								checked={colors === value}
								value={value}
								name='colors'
								onChange={setColors}
							/>{' '}
							{label}
						</label>
					</div>
				))}
			</form>
		</OptionCard>
	)
}

export default Colors
