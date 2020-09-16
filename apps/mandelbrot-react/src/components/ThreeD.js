import React from 'react'
import OptionCard from './OptionCard'
import store from '../store'

export const threeDs = [
	{
		value: false,
		label: '2-D',
	},
	{
		value: true,
		label: '3-D',
	},
	// {
	// 	value: true,
	// 	label: 'Stereo 3-D',
	// },
]

const Renderer = () => {
	const { three_d, setThreeD } = store()

	return (
		<OptionCard>
			<div className='title'>3-D</div>

			<form>
				{threeDs.map(({ label, value }, idx) => (
					<div key={idx}>
						<label>
							<input
								type='radio'
								checked={three_d === value}
								value={value}
								name='three_d'
								onChange={setThreeD}
							/>{' '}
							{label}
						</label>
					</div>
				))}
			</form>
		</OptionCard>
	)
}

export default Renderer
